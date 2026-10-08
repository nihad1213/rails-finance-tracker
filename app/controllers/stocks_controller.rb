class StocksController < ApplicationController
  before_action :authenticate_user!

  rescue_from MarketstackClient::Error do |e|
    redirect_back fallback_location: root_path, alert: e.message
  end

  def search
    @query = params[:q].to_s.strip
    @results = @query.present? ? MarketstackClient.new.search_tickers(@query) : []
  end

  def show
    @stock = Stock.find_or_fetch(params[:symbol])
    @history = Rails.cache.fetch("eod_history/#{@stock.symbol}", expires_in: 12.hours) do
      MarketstackClient.new.eod_history(@stock.symbol, days: 30)
    end
    @in_portfolio = current_user.stocks.exists?(@stock.id)
  end
end
