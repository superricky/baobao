json.array!(@accounts) do |account|
  json.extract! account, :login_id, :name, :email, :password_digest, :remember_token, :last_login_ip, :account_type, :phone
  json.url account_url(account, format: :json)
end
