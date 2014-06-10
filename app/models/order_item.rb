class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
  validates :product_unit, presence: true

  scope :popular_order_items_of_week, ->(shop) { joins(:order).where("orders.created_at >= ? and orders.shop_id = ? ", 7.days.ago.strftime('%Y-%m-%d'), shop.id)}

  after_create :update_stock, if: 'product.present? and product.branch.check_stock'
  private

  def update_stock
    self.product.decrement(:stock, self.quantity)
    self.product.save
  end
end
