require "net/http"
require "json"

class MarketStackClient
  class Error < StandardError; end
  class NotFound < Error; end

  BASE_URL = "http://api.marketstack.com/v1".freeze

  def initialize(api_key: ENV["MARKETSTACK_API_KEY"])
    @api_key = api_key
    raise Error, "MARKETSTACK_API_KEY is missing" if @api_key.blank?
  end

  def search_tickers(query, limit: 10)
    get("tickers", search: query, limit: limit).fetch("data", [])
  end

  def ticker(symbol)
    get("tickers/#{symbol}")
  end

  def latest_eod(symbol)
    get("eod/latest", symbols: symbol).fetch("data", []).first or raise NotFound, "No data for #{symbol}"
  end

  def eod_history(symbol, days: 30)
    get("eod", symbols: symbol, date_from: days.days.ago.to_date.to_s, limit: days).fetch("data", [])
  end

  private

  def get(path, params = {})
    uri = URI("#{BASE_URL}/#{path}")
    uri.query = URI.encode_www_form(params.merge(access_key: @api_key))

    response = Net::HTTP.start(uri.host, uri.port, open_timeout: 5, read_timeout: 10) do |http|
      http.get(uri.request_uri)
    end

    body = JSON.parse(response.body)
    if body["error"]
      msg = body["error"]["message"] || "Marketstack error"
      raise NotFound, msg if body["error"]["code"].to_s.include?("not_found")
      raise Error, msg
    end
    body
  rescue JSON::ParserError, SocketError, Net::OpenTimeout, Net::ReadTimeout => e
    raise Error, "Could not reach Marketstack: #{e.message}"
  end
end
