json.array!(@events) do |event|
  json.extract! event, :event, :event_key, :material_id
  json.url event_url(event, format: :json)
end
