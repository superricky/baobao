class CartMember < Cart
  belongs_to :user, class_name: Member.name
end
