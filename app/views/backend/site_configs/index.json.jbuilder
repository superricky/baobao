json.array!(@site_configs) do |site_config|
  json.extract! site_config, :key, :display_name, :value_type, :value_s, :value_b
  json.url site_config_url(site_config, format: :json)
end
