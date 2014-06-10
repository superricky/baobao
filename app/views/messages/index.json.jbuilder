json.array!(@messages) do |message|
  json.extract! message, :msg_id, :to_user_name, :from_user_name, :create_time, :msg_type, :content, :pic_url, :location_x, :location_y, :scale, :label, :title, :description, :url, :event, :event_key, :message_thread_id
  json.url message_url(message, format: :json)
end
