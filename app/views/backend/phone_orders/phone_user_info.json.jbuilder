if @phone_users.present?
  json.phone_user_list render partial: "phone_users_select.html.haml", locals: {phone_users: @phone_users}
end