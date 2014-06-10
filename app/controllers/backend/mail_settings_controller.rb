#encoding: utf-8
class Backend::MailSettingsController < BackendApplicationController

  before_action :set_mail_setting
  # GET /mail_settings/1
  # GET /mail_settings/1.json
  def show
  end

  # GET /mail_settings/1/edit
  def edit
  end

  # PATCH/PUT /mail_settings/1
  # PATCH/PUT /mail_settings/1.json
  def update
    respond_to do |format|
      if @mail_setting.update(mail_setting_params)
        format.html { redirect_to backend_shop_mail_settings_path(@current_shop.slug), notice: t('Mail setting was successfully updated.') }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def test_config_email
    begin
      AccountMailer.test_config_mailer(@current_shop).deliver
      notice = t "please check receive email"
    rescue => e
      logger.error e.message
      notice = t "email configuration is not successful"
      notice += "失败原因：#{e.message}"
    end
   redirect_to backend_shop_mail_settings_path(@current_shop.slug), notice: notice
  end

  private
    def set_mail_setting
      @mail_setting = @current_shop.mail_setting
      if @mail_setting.nil?
        @mail_setting = @current_shop.create_mail_setting
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mail_setting_params
      params.require(:mail_setting).permit(:enable_mail, :use_system_setting, :delivery_method, :address, :port,
      :domain, :user_name, :password, :authentication, :enable_starttls_auto, :reply_to, :notify_shop_manager)
    end
end
