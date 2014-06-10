class ValidatedPhone < ActiveRecord::Base
  belongs_to :phone_owner, :class_name => "BaseUser"
  validates :phone, presence: true, format: {with: VALID_PHONE_REGEX }
end
