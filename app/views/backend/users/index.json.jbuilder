json.array!(@users) do |user|
  json.extract! user, :phone, :default_address, :name, :fake_user_name, :email_address, :subscribe_time, :last_login_ip
  json.url user_url(user, format: :json)
end
