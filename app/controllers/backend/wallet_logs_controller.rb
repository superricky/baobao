#encoding: utf-8
class Backend::WalletLogsController < BackendApplicationController
  before_action :set_wallet_log, only: [:show, :edit, :update, :destroy, :rollback_recharge]

  # GET /wallet_logs
  # GET /wallet_logs.json
  def index
    if @current_branch.present?
      @q= @current_branch.wallet_logs.search(params[:q])
    elsif @current_shop.present?
      @q= @current_shop.wallet_logs.search(params[:q])
    end
    @wallet_logs = @q.result(distinct: true).paginate(:page => 1, :per_page => 25)
  end

  def search
    index
    render :index
  end

  # GET /wallet_logs/1
  # GET /wallet_logs/1.json
  def show
  end

  # GET /wallet_logs/new
  def new
     if @current_branch.present?
      @wallet_log = @current_branch.wallet_logs.build
      @wallet_log.shop = @current_shop
      @wallet_log.account = @current_account
      @wallet_log.branch = @current_branch
      @wallet_log.user = @current_branch.users.find(params[:user_id])
    end
  end

  # GET /wallet_logs/1/edit
  def edit
  end

  # POST /wallet_logs
  # POST /wallet_logs.json
  def create
    @wallet_log = @current_branch.wallet_logs.build(wallet_log_params)
    @wallet_log.shop = @current_shop
    @wallet_log.account = @current_account
    @wallet_log.branch = @current_branch
    @wallet_log.credit_log_type = WalletLog::WALLET_LOG_TYPE_RECHARGE

    respond_to do |format|
      begin
        if @wallet_log.save_recharge_wallet
          format.html { redirect_to get_user_path(@wallet_log.user), notice: '余额充值成功' }
          format.json { render action: 'show', status: :created, location: @wallet_log }
        else
          format.html { render action: 'new' }
          format.json { render json: @wallet_log.errors, status: :unprocessable_entity }
        end
      rescue => e
        format.html { render action: 'new' }
        format.json { render json: @wallet_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wallet_logs/1
  # PATCH/PUT /wallet_logs/1.json
  def update
    respond_to do |format|
      if @wallet_log.update(wallet_log_params)
        format.html { redirect_to backend_shop_wallet_log_path(@current_shop.slug, @wallet_log), notice: 'Wallet log was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @wallet_log.errors, status: :unprocessable_entity }
      end
    end
  end

  def rollback_recharge
    if @wallet_log.wallet_log_type != WalletLog::WALLET_LOG_TYPE_RECHARGE
      notice = "请确保类型流水类型为充值!"
    elsif @wallet_log.back_recharge_log.present?
      notice = "余额回退失败：充值余额已经回退"
    elsif not @wallet_log.recharge_can_rollback
      notice = "余额回退失败：充值的余额已被使用，无法回退！"
    else
      new_wallet_log = @current_shop.wallet_logs.new(money: @wallet_log.money, recharge_log: @wallet_log  ,note: "余额充值回退")
      new_wallet_log.user = @wallet_log.user
      new_wallet_log.account = @current_account
      new_wallet_log.wallet_log_type = WalletLog::WALLET_LOG_TYPE_RECHARGE_ROLLBACK
      if new_wallet_log.save
        notice = "消费积分回退成功!"
      else
        notice = "余额回退失败：请确认是否已经回退"
      end
    end
    url = backend_shop_user_path(@current_shop.slug, new_wallet_log.user, log_type: "wallet_logs")
    redirect_to url, notice: notice
  end

  # DELETE /wallet_logs/1

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wallet_log
       if @current_branch.present?
        @wallet_log = @current_branch.wallet_logs.find(params[:id])
      elsif @current_shop.present?
        @wallet_log = @current_shop.wallet_logs.find(params[:id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wallet_log_params
      if params[:action] == "create"
        params.require(:wallet_log).permit(:money, :user_id, :note)
      elsif params[:action] == "update"
        params.require(:wallet_log).permit(:note)
      end
    end
end
