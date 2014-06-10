class PhoneOrder < Order
  belongs_to :user, class_name: PhoneUser.name
end