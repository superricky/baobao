json.extract! @current_shop, :id, :name, :introduction, :use_sms_validation
json.image @current_shop.image.medium.url
json.qrcode @current_shop.qrcode.medium.url
json.current_currency_symbol @current_shop.current_currency_symbol

json.branches @current_shop.online_branches.each do |branch|
  json.is_on_service branch.is_on_service?
  json.extract! branch, :id, :name, :service_period_start, :service_period_end, :use_sms_validation
  json.image branch.image.medium.url
end