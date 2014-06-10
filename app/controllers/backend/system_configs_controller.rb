#encoding: utf-8
class Backend::SystemConfigsController < BackendApplicationController

  before_filter :set_system_config, only: [:show, :edit, :destroy, :update, :copy_menu_to_other]
  # GET /system_configs
  # GET /system_configs.json
  def index
    @system_configs = @current_shop.system_configs
  end

  # GET /system_configs/new
  def new
    @system_config = @current_shop.system_configs.build
    @wechat = Wechat.new
  end

  def auto_config_create
    @wechat = Wechat.new(params[:username], params[:password])
    @wechat.init(@current_shop, "#{request.protocol}#{request.host}", params[:system_config_id])
    if @wechat.login
      begin
      @wechat.toggle_dev_mode(1,2)
      @system_config = @wechat.configure_callback
      sleep 1.5
      @system_config = @wechat.config_dev_profile(@system_config)

      rescue Exception => e
        flash[:error] = e.message
        render 'edit'
        return
      end
      flash[:success] = "您的公众账户已经对接成功，为了方便您下次更好的识别您的公众帐号，您可以编辑您的公众帐号名称及类型。如需支持菜单功能，请设置appId和AppSecret"
      redirect_to backend_shop_system_config_path(@current_shop.slug, @system_config)

    elsif params[:system_config_id].present?
      @system_config = @current_shop.system_configs.find(params[:system_config_id])
      flash[:error] = "您的微信公众平台登录帐号或密码有误，请检查后重新输入..."
      render 'edit'
    else
      @system_config = @current_shop.system_configs.build
      flash[:error] = "您的微信公众平台登录帐号或密码有误，请检查后重新输入..."
      render 'new'
    end
  end


  def copy_menu_to_other
    target_system_configs = @current_shop.system_configs.find(params[:target_system_config_ids]) rescue nil
    if target_system_configs.present? and !target_system_configs.empty?
      target_system_configs.each do |target_system_config|
        target_system_config.menus += @system_config.menus
      end
    else
      @errors = []
      @errors << "对不起, 您尚未选择您要复制菜单的目标公众账号"
    end

    respond_to do |format|
      format.js {}
    end
  end

  def show
  end

  def edit
    @wechat = Wechat.new
  end

  def destroy
    @system_config.destroy
    redirect_to backend_shop_system_configs_path(@current_shop.slug)
  end

  def create
    @system_config = @current_shop.system_configs.build(system_config_params)
    respond_to do |format|
      if @system_config.save
        format.html { redirect_to backend_shop_system_config_path(@current_shop, @system_config), notice: "恭喜您，公众账号已经成功创建"}
        format.json { render action: 'show', status: :created, location: @system_config }
      else
        @wechat = Wechat.new
        format.html { render action: 'new' }
        format.json { render json: @system_config.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @system_config.update_attributes(system_config_params)
        format.html { redirect_to backend_shop_system_config_path(@current_shop.slug, @system_config), notice: t('System config was successfully created.') }
        format.json { render action: 'show', status: :created, location: @system_config }
      else
        @wechat = Wechat.new
        format.html { render action: 'edit' }
        format.json { render json: @system_config.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def system_config_params
      params.require(:system_config).permit(:url, :token, :gonghao_type, :appId, :appSecret,
        :my_fake_id, :public_account_name, :be_verified)
    end

    def set_system_config
      @system_config = @current_shop.system_configs.find(params[:id])
    end
end
