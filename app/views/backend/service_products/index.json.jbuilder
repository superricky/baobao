json.array!(@service_products) do |service_product|
  json.extract! service_product, :id, :subject, :price, :description
  json.url service_product_url(service_product, format: :json)
end
