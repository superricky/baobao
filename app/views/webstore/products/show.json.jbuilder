json.extract! @product, :id, :name, :stock, :category_ids, :description
json.image do
  json.thumb @product.image.thumb.url
  json.medium @product.image.medium.url
end
json.original_price @product.original_price
json.price @product.price