json.extract! order, :id, :name, :amount, :phone, :address, :guest_num, :desk_no, :note, :shop, :form_contents, :delivery_zone_id
json.created_at order.created_at.strftime("%Y-%m-%d %H:%M")
json.order_items order.order_items do |item|
  json.extract! item, :name, :price, :product_unit, :quantity
  json.image do
    json.thumb item.product.image.thumb.url rescue nil
    json.medium item.product.image.medium.url rescue nil
  end
end