json.array!(@product_sliders) do |product_slider|
  json.extract! product_slider, :id, :img, :desc, :branch_id, :position, :product_id
  json.url product_slider_url(product_slider, format: :json)
end
