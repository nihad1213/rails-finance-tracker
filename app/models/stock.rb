class Stock < ApplicationRecord
  STALE_AFTER = 12.hours

  has_many :user_stocks, dependent: :destroy
  has_many :users, through: :user_stocks

  before_validation { self.symbol = symbol.to_s.strip.upcase }
  validates :symbol, presence: true, uniqueness: true

  def self.find_or_fetch(symbol)
    stock = find_or_initialize_by(symbol: symbol.to_s.strip.upcase)
    stock.refresh! if stock.new_record? || stock.stale?
    stock
  end

  def stale?
    last_fetched_at.nil? || last_fetched_at < STALE_AFTER.ago
  end

  def refresh!
    client = MarketstackClient.new
    price  = client.latest_eod(symbol)

    if name.blank?
      info = client.ticker(symbol) rescue {}
      self.name     = info["name"]
      self.exchange = info.dig("stock_exchange", "acronym")
    end

    update!(
      last_price: price["close"],
      last_price_date: price["date"]&.to_date,
      last_fetched_at: Time.current
    )
  end
end
