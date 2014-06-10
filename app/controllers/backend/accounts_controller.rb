require 'csv'
class Backend::AccountsController < BackendApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy, :edit_password, :reset_password, :update_password, :account_branch]
  before_filter :correct_account, only: [:update_password]
  before_filter :admin_account, only: [:destroy, :new, :reset_password]

  def index
    if @current_shop.nil?
      @accounts = Account.with_any_role(:account, Account::ACCOUNTYPE_SYSTEM_ADMIN).paginate(:page => params[:page], :per_page => 25)
    elsif @current_branch.nil?
      #@current_branch = @current_shop.branches.first
      @accounts = @current_shop.accounts.paginate(page: params[:page], :per_page => 25)
    else
      @accounts = @current_branch.accounts.with_any_role(:account, Account::ACCOUNTYPE_SHOP_WORKER).paginate(page: params[:page], :per_page => 25)
    end
  end

  def show
  end

  def new
    if @current_shop.nil?
      @account = Account.new
    elsif @current_branch.nil?
      @account = @current_shop.accounts.build
    else
      @account = @current_branch.accounts.build
    end
  end

  def export_accounts
    day_str = "#{params[:date][:year]}-#{params[:date][:month]}-#{params[:date][:day]}"
    for_day = Date.parse(day_str)
    shops = Shop.where(:created_at=>for_day.beginning_of_day..for_day.end_of_day)
    accounts = []
    shops.each do |shop|
      shop.accounts.each do |account|
        if account.is_boss?
          accounts << account
        end
      end
    end
    respond_to do |format|
      format.csv { send_data Account.to_csv(accounts,col_sep: ","), :filename => "accounts_#{day_str}.csv" }
    end
  end

  # GET /accounts/1/edit
  def edit

  end

  def account_branch
    @branches = @account.branches
  end

  # POST /accounts
  # POST /accounts.json
  def create
    if current_account.is_admin?
      @account = @current_shop.accounts.build(account_params)
      if [Account::ACCOUNTYPE_SHOP_WORKER, Account::ACCOUNTYPE_SHOP_BOSS].include?(account_params[:account_role])
        @account.add_role account_params[:account_role]
      end
    elsif current_account.is_boss?
      @account = @current_shop.accounts.build(account_params)
      if @current_branch.present?
        @account.branch_ids = @current_branch.id
      end
      @account.add_role Account::ACCOUNTYPE_SHOP_WORKER
    else
      @account.errors[:account_role] = '对不起，您无权创建账户';
      render 'new'
      return
    end


    if @account.save
      begin
        AccountMailer.welcome_email(@account , request.host_with_port).deliver
      rescue => e
        logger.error e.message
      end
      flash[:success] = t("Account has been created successfully!")
      redirect_to get_accounts_path
      return
    else
      render 'new'
    end
  end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  def update
    if (current_account.is_admin? or current_account.is_boss? ) and [Account::ACCOUNTYPE_SHOP_WORKER, Account::ACCOUNTYPE_SHOP_BOSS].include?(account_params[:account_role])
      @account.account_add_role account_params[:account_role]
    else
      @account.errors[:account_role] = '对不起，您无权修改账户';
      render 'edit'
      return
    end

    if @account.update_attributes(account_params)
      flash[:success] = t("Profile updated")
      if current_account?(@account)
        sign_in @account
        render 'show'
      else
        redirect_to get_account_path(@account)
      end
    else
      render 'edit'
    end
  end

  def edit_password
    unless current_account?(@account)
      redirect_to backend_login_path, notice: t('no permision to update other people\'s password')
    end
  end

  def show_my_account
    @account = current_account
  end

  def config_my_account
    @account = current_account
  end

  def edit_my_password
    @account = current_account
  end

  include AccountsHelper

  def update_my_password
    @account = current_account
    if (not @account.nil?) and @account.valid_password? update_password_params[:old_password]
      setup_new_password update_password_params, 'edit_my_password', get_show_my_account_path
    else
      @account.errors[:old_password] = t('original password not correct !')
      render 'edit_my_password'
    end
  end

  def update_my_account
    @account = current_account
    respond_to do |format|
      if @account.update(account_params)
        sign_in @account
        format.html { redirect_to get_show_my_account_path, notice: t('Shop was successfully updated.') }
      else
        format.html { render action: 'config_my_account' }
      end
    end
  end

  def reset_password
    if current_account?(@account)
      redirect_to  edit_password_backend_shop_account_path(@current_shop, @account)
    end
  end

  def update_password
    if current_account?(@account)
      if (not @account.nil?) and @account.valid_password? update_password_params[:old_password]
        setup_new_password update_password_params, 'edit_password', backend_shop_account_path(@current_shop, @account)
      else
        @account.errors[:old_password] = t('original password not correct !')
        render 'edit_password'
      end

    else
      setup_new_password reset_password_params, 'reset_password', get_accounts_path
    end
  end

  def admin_account
    redirect_to root_path unless current_account.is_admin? or current_account.is_boss?
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account.destroy
    flash[:success] = t("Account destroyed.")
    redirect_to get_accounts_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_account
    if @current_shop.nil?
      @account = Account.find(params[:id])
    elsif @current_branch.nil?
      @account = @current_shop.accounts.find(params[:id])
    else
      @account = @current_branch.accounts.find(params[:id])
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def account_params
    if(current_account.is_admin?)
      params.require(:account).permit(:login_id, :name, :email, :password, :password_confirmation, :phone, :shop_id, :branch_id, :account_role, :old_password, :user_id, branch_ids: [])
    else
      params.require(:account).permit(:login_id, :name, :email, :phone, :password, :password_confirmation, :branch_id, :old_password, :account_role, :user_id, branch_ids: [])
    end
  end

  def reset_password_params
    params.require(:account).permit(:password, :password_confirmation)
  end

  def update_password_params
    params.require(:account).permit(:old_password, :password, :password_confirmation)
  end

  def correct_account
    redirect_to(backend_login_path) unless current_account?(@account) or current_account.is_admin? or
      (current_account.is_boss? and @account.is_worker?)
  end

  def setup_new_password(password_params, render_template, success_path)
    is_myself = false
    if current_account?(@account)
    is_myself = true
    end
    if @account.update_attributes(:password=>password_params[:password],
    :password_confirmation => password_params[:password_confirmation])
      if is_myself
        sign_in @account
      end
      redirect_to success_path, :notice => t('password has been updated successfully!')
    else
      render render_template
    end
  end
end