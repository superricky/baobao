class Cart < ActiveRecord::Base
  has_many :line_items, :dependent => :destroy
  belongs_to :shop
  belongs_to :user
  belongs_to :branch, counter_cache: true
  
  def line_items_count
    total = 0;
    line_items.each{|line_item|
      total += line_item.quantity
     }
     total
  end
  
  def line_items_amount
    amount = 0;
    line_items.each{|line_item|
      amount += line_item.quantity * line_item.product.price
     }
     amount
  end
end
