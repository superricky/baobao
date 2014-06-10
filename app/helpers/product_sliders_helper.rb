#encoding: utf-8
module ProductSlidersHelper
  def get_product_slider_position_select_option
    options = [["置顶", "move_to_top"]]
    if @current_branch.product_sliders.present?
      @current_branch.product_sliders.each_with_index do |product_slider, index|
        options << ["第#{index+1}位", index+1]
      end
    end
    options << ["埋底", "move_to_bottom"]
  end
end
