#encoding: utf-8
module BranchSlidersHelper
  def get_branch_slider_position_select_option
    options = [["置顶", "move_to_top"]]
    if @current_shop.branch_sliders.present?
      @current_shop.branch_sliders.each_with_index do |branch_slider, index|
        options << ["第#{index+1}位", index+1]
      end
    end
    options << ["埋底", "move_to_bottom"]
  end
end
