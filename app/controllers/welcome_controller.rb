class WelcomeController < ApplicationController
  def index
    @user_stocks = user_signed_in? ? current_user.user_stocks.includes(:stock).limit(5) : []
  end
end
