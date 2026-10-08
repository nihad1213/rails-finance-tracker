class UserStock < ApplicationRecord
  belongs_to :user
  belongs_to :stock
  # add_index :user_stocks, [ :user_id, :stock_id ], unique: true
  validates :stock_id, uniqueness: { scope: :user_id, message: "is already in your portfolio" }
end
