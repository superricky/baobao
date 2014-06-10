json.extract! @user, :phone, :default_address, :name, :fake_user_name, :email_address, :subscribe_time, :last_login_ip, :created_at, :updated_at, :is_apply_vip_user
if @user.vip_level.present?
  json.vip_level_name @user.vip_level.name
end
