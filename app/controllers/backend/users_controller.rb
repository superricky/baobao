#encoding: utf-8
include UsersHelper
class Backend::UsersController < BackendApplicationController
  before_action :set_user, only: [:vip_edit, :show, :edit, :reset_validation_code_times, :update, :destroy, :block, :recharge, :search_log, :approve_vip_user, :create_vip_user]
  before_filter :check_has_boss_priv, only: [:appling_vip, :approve_vip_user, :create_vip_user]
  skip_load_and_authorize_resource
  authorize_resource :class => false
  # GET /users
  # GET /users.json
  def index
    if @current_branch.present?
      @q = @current_branch.users.where(type: params[:type]).search(params[:q])
    else
      @q = BaseUser.where(shop_id: @current_shop.id, type: params[:type]).search(params[:q])
    end
    @users = @q.result(distinct: true)
    @users = @users.paginate(:page => params[:page], :per_page => 25)
  end

  def appling_vip
    @users = @current_shop.users.appling_vips.paginate(:page => params[:page], :per_page => 25)
  end

  def approve_vip_user
  end

  def create_vip_user
    unless user_params[:vip_no].present?
      @user.errors.add(:vip_no, '不能为空')
    end

    unless user_params[:vip_level_id].present?
      @user.errors.add(:vip_level_id, '不能为空')
    end

    if @user.errors.any?
      return render 'approve_vip_user'
    end



    if @user.update_attributes(:vip_no=>user_params[:vip_no], :vip_level_id=>user_params[:vip_level_id], :is_apply_vip_user=>false)
      flash[:notice] = t('User was successfully updated.');
      redirect_to approve_vip_user_backend_shop_user_path(@current_shop.slug, @user)
      return
    end
    render 'approve_vip_user'
  end

  def search
    if params[:q][:vip_present] == "0"
      params[:q][:vip_blank] = "1"
    end
    index
    params[:q][:vip_present] ||= 0
    render :index
  end

  # GET /users/1
  # GET /users/1.json
  def show
    if params[:log_type] == "credits_logs"
      @q = @user.credits_logs.search(params[:q])
      @credits_logs = @q.result(distinct: true).order("created_at DESC")
    elsif params[:log_type] == "wallet_logs"
      @q = @user.wallet_logs.search(params[:q])
      @wallet_logs = @q.result(distinct: true).order("created_at DESC")
    end
  end

  def search_log
    show
    render "show"
  end

  def myprofile
    @user = current_user
  end

  def update_myprofile
    @user = current_user
    if @user.update(user_params)
      redirect_to backend_shop_branch_myprofile_path(@current_shop.slug, @current_branch), notice: "您的个人信息已经更新成功"
    else
      render action: 'myprofile'
    end
  end

  # GET /users/1/edit
  def edit
  end

  def reset_validation_code_times
    @user.sent_validation_code_times_in_today = 0;
    @user.save
    render 'show'
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to backend_shop_user_path(@current_shop.slug, @user), notice: t('User was successfully updated.') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def recharge
    if @user.recharge(current_account, user_params[:recharge_amount])
      redirect_to backend_shop_user_path(@current_shop.slug, @user, log_type: "wallet_logs"), notice: "恭喜，用户账户充值成功，当前账户余额为#{@user.wallet}"
    else
      render 'vip_edit'
    end
  end

  def block
    @user.update_attribute(:is_blocked, !@user.is_blocked)
    respond_to do |format|
      format.html { redirect_to get_users_path}
    end
  end

  def vip_edit
    unless @user.is_vip?
      flash[:error] = "请先为该用户设置会员等级和支付密码，才能为该用户充值"
      redirect_to get_edit_user_path(@user)
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to backend_shop_users_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      if @current_branch.present?
        @user = @current_branch.users.find(params[:id])
      else
        @user = BaseUser.where(shop_id: @current_shop.id).find(params[:id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      current_class = @user.class.name.underscore.to_sym if @user
      if @current_account.present? and (@current_account.is_admin? or @current_account.is_boss?)
        params.require(current_class || :user).permit(:phone, :default_address, :name,
          :email_address, :vip_no, :vip_level_id, :pay_password, :recharge_amount)
      else
        params.require(current_class || :user).permit(:phone, :default_address, :name, :email_address)
      end
    end
end
