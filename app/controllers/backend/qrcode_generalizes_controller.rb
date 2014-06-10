#encoding:utf-8
class Backend::QrcodeGeneralizesController < BackendApplicationController

  skip_load_and_authorize_resource
  authorize_resource :class => false

  def index
    @users = @current_shop.users.where.not(ticket: nil).order(audiences_count: :desc).paginate(:page => params[:page], :per_page => 20)
  end

  def promotion_user
    @user = @current_shop.users.find(params[:user_id])
    @wx_user_info = User.user_info_from_wx(@current_shop, @user.fake_user_name)
    respond_to do |format|
      format.js
    end
  end

  def user_generalizes
    @user = @current_shop.users.find(params[:user_id])
    @wx_user_info = User.user_info_from_wx(@current_shop, @user.fake_user_name)
    @audiences = @user.audiences.paginate(:page => params[:page], :per_page => 10)
  end
end