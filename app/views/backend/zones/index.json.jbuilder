json.array!(@zones) do |zone|
  json.extract! zone, :id, :name, :parent_zone_id, :shop_id
  json.url zone_url(zone, format: :json)
end
