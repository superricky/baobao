class OrderWebstore < Order
  belongs_to :user, class_name: Member.name, counter_cache: true
end
