#encoding:utf-8;
module Backend::CategoriesHelper
  def categories_options(current_shop, current_branch, product)
    categories = @current_branch.categories.where(category_id: 0).includes(:categories)
    selected_categories = product.categories.collect{|c| c.id}
    htmls = []
    categories.each do |category|
      selected = selected_categories.include? category.id
      htmls << "<optgroup label=#{category.name}>"
      htmls << "<option value=#{category.id} #{selected ? "selected=selected" : ""}>#{category.name}(一级分类)</option>"
      category.categories.each do |subcategory|
        selected = selected_categories.include? subcategory.id
        htmls << "<option value=#{subcategory.id} #{selected ? "selected=selected" : ""}>#{subcategory.name}(二级分类)</option>"
      end
      htmls << "</optgroup>"
    end
    htmls.join.html_safe
  end
end