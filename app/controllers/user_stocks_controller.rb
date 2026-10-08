class UserStocksController < ApplicationController
  before_action :authenticate_user!

  def index
    @user_stocks = current_user.user_stocks.includes(:stock).order("stocks.symbol")
  end

  def create
    stock = Stock.find_or_fetch(params[:symbol])
    current_user.user_stocks.create!(stock: stock)
    redirect_to user_stocks_path, notice: "#{stock.symbol} added to your portfolio."
  rescue MarketstackClient::Error, ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: root_path, alert: e.message
  end

  def destroy
    current_user.user_stocks.find(params[:id]).destroy
    redirect_to user_stocks_path, notice: "Removed from portfolio."
  end
end
