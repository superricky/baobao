json.array!(@message_threads) do |message_thread|
  json.extract! message_thread, :updated_at, :user_id
  json.url message_thread_url(message_thread, format: :json)
end
