class FrozenAsset < ActiveRecord::Base

  FROZEN_CREDITS = "credit"
  FROZEN_WALLET = "wallet"

  belongs_to :shop
  belongs_to :branch
  belongs_to :order
  belongs_to :user

  def is_credit_asset?
    frozen_type == FROZEN_CREDITS
  end

  def is_wallet_asset?
    frozen_type == FROZEN_WALLET
  end
end
