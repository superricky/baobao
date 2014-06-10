class TransactionLog < ActiveRecord::Base
  belongs_to :shop
  belongs_to :service_sale_order
  default_scope {order("created_at DESC")}
end
