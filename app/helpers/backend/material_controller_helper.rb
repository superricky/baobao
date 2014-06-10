module Backend::MaterialControllerHelper

  def get_article_position_select_option(record_list)
    options = [["置顶", "move_to_top"]]
    record_list.each_with_index do |record_item, index|
      options << ["第#{index+1}位", index+1]
    end
    options << ["埋底", "move_to_bottom"]
  end

end
