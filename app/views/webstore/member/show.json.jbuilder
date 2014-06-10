json.extract! @member, :id, :email, :phone, :default_address, :name, :shop_id
json.last_login_at @member.last_sign_in_at.strftime("%Y-%m-%d %H:%M:%S") rescue nil
json.last_sign_in_ip @member.last_sign_in_ip
json.validated_phones @member.validated_phones.map(&:phone)