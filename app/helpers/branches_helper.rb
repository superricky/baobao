module BranchesHelper

  def cut_introduction(introduction)
    if introduction.present? and introduction.length > 120
      "#{introduction.slice(0, 119)}..."
    else
      introduction
    end
  end

  def filter_by_delivery_radius(branches, customer_location)
    if customer_location.present?
      branches.select{ |branch|   branch.delivery_radius >= branch.distance_to(customer_location)}
    else
      branches
    end
  end
  def get_position_select_option(record_list)
    options = [["置顶", "move_to_top"]]
    record_list.total_entries.times do |index|
      options << ["第#{index + 1}位", (index + 1)]
    end
    options << ["埋底", "move_to_bottom"]
  end

  def get_position_number(record_list, index)
    ((record_list.current_page - 1) * record_list.per_page + index + 1)
  end
end
