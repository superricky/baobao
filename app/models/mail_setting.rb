class MailSetting < ActiveRecord::Base
  belongs_to :shop
  validates :shop, presence: true
  validates :address, :domain, :user_name, :password, :reply_to, presence:true, on: :update, unless: :use_system_setting
  validates :reply_to, format: {with: VALID_EMAIL_ADDRESS_REGEX }, :allow_blank => true
end
