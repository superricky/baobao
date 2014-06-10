json.array!(@branch_types) do |branch_type|
  json.extract! branch_type, :id, :name, :branches_count, :shop_id
  json.url branch_type_url(branch_type, format: :json)
end
