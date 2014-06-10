json.array!(@system_configs) do |system_config|
  json.extract! system_config, :url, :token, :appId, :appSecret, :my_fake_id, :print_on_order, :memberCode, :deviceNo, :apiKey
  json.url system_config_url(system_config, format: :json)
end
