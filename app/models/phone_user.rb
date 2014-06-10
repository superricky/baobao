#encoding: utf-8
class PhoneUser < BaseUser
  belongs_to :shop, foreign_key: "user_id"
  belongs_to :vip_level, counter_cache: true
end