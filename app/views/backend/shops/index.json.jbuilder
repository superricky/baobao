json.array!(@shops) do |shop|
  json.extract! shop, :name, :slug, :is_open, :service_period_start, :introduction, :service_period_end, :expiration_time, :notice, :orders_count, :income
  json.url shop_url(shop, format: :json)
end
