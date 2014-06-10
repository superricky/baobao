#encoding:utf-8
include UsersHelper
include CreditsLogsHelper
class Backend::CreditsLogsController < BackendApplicationController
  before_action :set_credits_log, only: [:show, :edit, :update, :destroy, :rollback_credits]

  # GET /credits_logs
  # GET /credits_logs.json
  def index
    if @current_branch.present?
      @q = @current_branch.credits_logs.search(params[:q])

    elsif @current_shop.present?
      @q = @current_shop.credits_logs.search(params[:q])
    end
    @credits_logs = @q.result(distinct: true).paginate(:page => params[:page], :per_page => 25)
  end

  def search
    index
    render "index"
  end

  # GET /credits_logs/1
  # GET /credits_logs/1.json
  def show
  end

  # GET /credits_logs/new
  def new
    if @current_branch.present?
      @credits_log = @current_branch.credits_logs.build
      @credits_log.shop = @current_shop
      @credits_log.account = @current_account
      @credits_log.branch = @current_branch
      @credits_log.user = @current_branch.users.find(params[:user_id])
    end
  end

  # GET /credits_logs/1/edit
  def edit
  end

  # POST /credits_logs
  # POST /credits_logs.json
  def create

    @credits_log = @current_branch.credits_logs.build(credits_log_params)
    @credits_log.shop = @current_shop
    @credits_log.account = @current_account
    @credits_log.credit_log_type = CreditsLog::CREDITS_LOG_TYPE_CONSUME

    respond_to do |format|
      begin
        if @credits_log.save
          format.html { redirect_to get_user_path(@credits_log.user), notice: '积分消费已成功创建' }
          format.json { render action: 'show', status: :created, location: @credits_log }
        else
          format.html { render action: 'new' }
          format.json { render json: @credits_log.errors, status: :unprocessable_entity }
        end
      rescue => e
        format.html { render action: 'new' }
        format.json { render json: @credits_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /credits_logs/1
  # PATCH/PUT /credits_logs/1.json
  def update
    respond_to do |format|
      if @credits_log.update(credits_log_params)
        format.html { redirect_to get_credits_log_path(@credits_log), notice: '消费备注更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @credits_log.errors, status: :unprocessable_entity }
      end
    end
  end

  def rollback_credits
    if @credits_log.credit_log_type != CreditsLog::CREDITS_LOG_TYPE_CONSUME
      notice = "请确保类型为积分换购类型!"
    elsif @credits_log.back_consume_log.present?
      notice = "积分回退失败：消费积分已经回退"
    else
      credits_log = @current_branch.credits_logs.build(credits: @credits_log.credits, consume_log: @credits_log  ,note: "换购积分归还用户")
      credits_log.shop = @current_shop
      credits_log.user = @credits_log.user
      credits_log.account = @current_account
      credits_log.credit_log_type = CreditsLog::CREDITS_LOG_TYPE_CONSUME_ROLLBACK
      if credits_log.save
        notice = "消费积分回退成功!"
      else
        notice = "积分回退失败：请确认是否已经回退"
      end
    end
    url = backend_shop_branch_user_path(@current_shop.slug, @current_branch, @credits_log.user, log_type: "credits_logs")
    redirect_to url, notice: notice
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_credits_log
      if @current_branch.present?
        @credits_log = @current_branch.credits_logs.find(params[:id])
      elsif @current_shop.present?
        @credits_log = @current_shop.credits_logs.find(params[:id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def credits_log_params
      if params[:action] == "create"
        params.require(:credits_log).permit(:credits, :user_id, :note)
      elsif params[:action] == "update"
        params.require(:credits_log).permit(:note)
      end
    end
end
