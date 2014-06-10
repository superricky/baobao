json.array!(@menus) do |menu|
  json.extract! menu, :name, :event_type, :event_id, :url, :parent_menu_id, :menu_type
  json.url menu_url(menu, format: :json)
end
