json.array!(@articles) do |article|
  json.extract! article, :title, :description, :image, :url, :material_id
  json.url article_url(article, format: :json)
end
