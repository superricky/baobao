json.array!(@custom_ui_settings) do |custom_ui_setting|
  json.extract! custom_ui_setting, :branch_id, :order_delivery_btn, :order_eat_in_hall_btn, :order_order_seat
  json.url custom_ui_setting_url(custom_ui_setting, format: :json)
end
