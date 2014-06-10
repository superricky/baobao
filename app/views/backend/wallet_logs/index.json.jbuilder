json.array!(@wallet_logs) do |wallet_log|
  json.extract! wallet_log, :id, :user_id, :wallet_log_type, :money, :note
  json.url wallet_log_url(wallet_log, format: :json)
end
