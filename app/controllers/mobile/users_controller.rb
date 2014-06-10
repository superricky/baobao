#encoding: utf-8
include UsersHelper
class Mobile::UsersController < MobileApplicationController
  before_filter :set_cart_id, only: [:myprofile, :update_myprofile, :account]

  def account

  end

  def myprofile
    @user = current_user
  end

  def update_myprofile
    @user = current_user
    if @user.update(user_params)
      redirect_to mobile_shop_branch_myprofile_path(@current_shop.slug, @current_branch), notice: "您的个人信息已经更新成功"
    else
      render action: 'myprofile'
    end
  end

  private
    def user_params
      params.require(:user).permit(:phone, :default_address, :name, :email_address)
    end
end
