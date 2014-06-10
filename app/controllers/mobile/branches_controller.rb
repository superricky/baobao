#encoding: utf-8
class Mobile::BranchesController < MobileApplicationController
  before_filter :set_cart_id, only: [:list, :about_my_shop]
  before_action :set_branch, only: :about_my_shop

  def list
    impressionist(@current_shop, '',  unique: [:controller_name, :action_name, :session_hash, :user_id])
    if @current_shop.enable_new_version
      redirect_to client_weixinpay_path(@current_shop.slug)
      return
    end
    if params[:branch_type].present? && params[:branch_type].to_i > 0
      @branches = Branch.active_branches_by_shop_brand_chains_and_join_branch_types(@current_shop, params[:branch_type])
    elsif params[:zone].present? && params[:zone].to_i > 0
      @branches = Branch.active_branches_by_shop_brand_chains_and_join_zones(@current_shop, params[:zone])
    else
      @branches = Branch.active_branches_with_brand_chains_by_shop(@current_shop)
    end
    @slides = @current_shop.branch_sliders
    render layout: 'mobile/application'
  end

  def about_my_shop
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_branch
    @branch = @current_shop.branches.find(params[:id])
    @current_branch = @branch
  end
end
