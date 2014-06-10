json.array!(@post_threads) do |post_thread|
  json.extract! post_thread, :id, :title, :content, :last_requestd_at, :requested_times, :account_id, :workflow_state
  json.url post_thread_url(post_thread, format: :json)
end
