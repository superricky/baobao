json.array!(@post_thread_labels) do |post_thread_label|
  json.extract! post_thread_label, :id, :name
  json.url post_thread_label_url(post_thread_label, format: :json)
end
