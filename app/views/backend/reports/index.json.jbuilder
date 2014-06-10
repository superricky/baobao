json.array!(@reports) do |report|
  json.extract! report, :id, :title, :author, :content, :shop_id
  json.url report_url(report, format: :json)
end
