json.array!(@product_units) do |product_unit|
  json.extract! product_unit, :name
  json.url product_unit_url(product_unit, format: :json)
end
