#encoding:utf-8;
module Mobile::ApplicationHelper

  def group_products(products = @products)
    return [] unless products
    groups = []
    group = []
    switch = 0
    times = 0
    products.each_with_index do |product, i|
      break groups << (group << products.first) if products.length == 1
      if i > 0 && (i-times) % 5 == 0 && 0 == switch
        groups << group
        group = []
        switch = 1
      end

      if i > 0 && (i-times) % 11 == 0 && 1 == switch
        groups << group
        group = []
        times += 11
        switch = 0
      end
      group << product
    end

    if group.length == 1
      if groups[-1].present? and groups[-1].length == 5
        groups[-1] += group
        return groups
      end
      if groups[-2].present? and groups[-2].length == 5
        groups[-2] += group
        return groups
      end
    else
      groups << group
    end
    groups
  end

  def lateral_or_vertial(group, product)
    return "lateral" if group.length % 2 == 0
    group.index(product) == 0 ? "vertial-2" : "lateral"
  end

  def currency_symbol
    @current_shop.current_currency_symbol
  end

  def can_make_a_call
    @current_branch.telephone.present?
  end

  def mobile_branch_types
    @current_shop.branch_types.includes(:branches)
  end

  def monile_zones
    @current_shop.zones.includes(:branches)
  end
end
