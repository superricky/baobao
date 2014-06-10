#encoding: utf-8
class CartPhoneUser < Cart
  belongs_to :user, class_name: PhoneUser.name
end