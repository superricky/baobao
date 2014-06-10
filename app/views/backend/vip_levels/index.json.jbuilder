json.array!(@vip_levels) do |vip_level|
  json.extract! vip_level, :id, :shop_id, :name, :discount
  json.url vip_level_url(vip_level, format: :json)
end
