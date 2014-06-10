json.extract! @current_branch, :id, :name, :notice, :use_sms_validation, :introduction, :longitude, :latitude, :telephone, :address, :min_order_time_gap, :use_min_order_charge, :min_order_charge, :non_service_order_charge, :delivery_radius_txt, :delivery_radius,
:fixed_delivery_time
json.image @current_branch.image.medium.url
json.is_on_service @current_branch.is_on_service?
json.service_period_start @current_branch.service_period_start.strftime("%H:%M")
json.service_period_end @current_branch.service_period_end.strftime("%H:%M")

json.delivery_zones @current_branch.delivery_zones.each do |zone|
  json.extract! zone, :id, :zone_name, :charge
end

json.categories @categories.uniq.each do |category|
  json.extract! category, :name, :id
  json.products category.products.each do |product|
    json.extract! product, :id, :name, :stock, :category_ids, :product_unit
    json.description strip_tags(product.description)
    json.image do
      json.thumb product.image.thumb.url
      json.medium product.image.medium.url
    end
    json.price product.original_price
  end
end

if @current_branch.fixed_delivery_time
  json.select_delivery_times @current_branch.select_delivery_times.each do |delivery_time|
    json.time_period "#{delivery_time.delivery_time_start.strftime("%H:%M")}~~#{delivery_time.delivery_time_end.strftime("%H:%M")}"
    json.time_advance delivery_time.time_advance
  end
  json.delivery_times @current_branch.delivery_times.each do |time|
    json.time_period "#{time.delivery_time_start.strftime("%H:%M")}~~#{time.delivery_time_end.strftime("%H:%M")}"
    json.time_advance time.time_advance
  end
end

json.form_elements FormElement.by_branch_with_options(@current_branch) do |form_element|
  json.id form_element.id
  json.label form_element.statement
  json.type form_element.type
  json.placeholder form_element.placeholder if form_element.placeholder.present?
  json.need form_element.need if form_element.need && form_element.need.present?
  if form_element.options.present?
    json.options form_element.options do |option|
      json.option_id option.id
      json.html option.statement
    end
    json.options_hash Hash[form_element.options.map{|o| [o.id, o.statement]}]
  end
  json.regex FormElement::Regexs[form_element.regex.to_sym].source if form_element.regex && form_element.regex != "none"
  json.need true if form_element.need

  if form_element.is_a? FormElementText
    json.record do
      json.type "string"
      json.form_element_id form_element.id
      json.content ""
    end
  end
  if form_element.is_a? FormElementSelect
    json.record do
      json.type "quote"
      json.form_element_id form_element.id
      json.content form_element.options.first.id rescue nil
    end
  end
end

json.hot_products_of_week @hot_products_of_week.each do |product|
  json.extract! product, :id
end
