class Backend::ShopStepsController < BackendApplicationController
  include Wicked::Wizard
  skip_load_and_authorize_resource
  authorize_resource :class => false
  prepend_before_filter :set_steps

  steps :shop_info, :sms_message, :credit, :wallet,:promotion

  def show
    @shop = @current_shop
    render_wizard
  end

  def update
    @shop = @current_shop
    @shop.update(shop_params)
    render_wizard @shop
  end

  private
    def set_steps
      if params[:edit].present?
        @executed_steps = self.steps = [params[:id].to_sym]
      else
        @executed_steps = self.steps[0..(self.steps.index(params[:id].to_sym))] rescue nil
      end
    end

    def finish_wizard_path
      flash[:notice] = t("Shop was successfully setted")
      backend_shop_path(@shop)
    end

    def shop_params
      params[:shop][:enable_new_version] = false if params[:shop] && params[:shop][:enable_new_version].present?
      if request.domain.present?
        params[:shop][:domain] = "" if (params[:shop][:domain] && params[:shop][:domain].include?(request.domain)) || params[:shop][:domain] == request.host
      end
      if current_account.is_admin?
        params.require(:shop).permit(:qrcode, :name, :slug, :introduction, :is_open,
          :expiration_time, :telephone, :max_branches_count, :image, :image_cache,
          :default_reply_content_type, :charge_method, :left_order_count, :welcome_msg,
          :use_sms, :max_sms_count, :use_sms_validation, :aid,
          :max_validation_code_times_in_day, :use_credits, :money_for_each_credit,
          :support_wallet_pay, :support_credits_pay, :credit_for_each_money, :enable_new_version,
          :hide_support_company, :max_branch_sliders, :award_credits_at_follow, :award_credits , :enable_foreign_currency, :foreign_currency_symbol, :reply_num_of_orders,
          :least_promotion_number, :state, :product_image_limit, :product_slider_limit, :support_auto_buy_service, :support_link_name, :support_link, :domain, :copy_right_footer)
      else
        params.require(:shop).permit(:name, :qrcode, :introduction, :telephone,:image, :default_reply_content_type,
        :welcome_msg, :use_sms, :use_sms_validation, :max_validation_code_times_in_day,
        :use_credits, :money_for_each_credit, :enable_new_version, :enable_foreign_currency, :foreign_currency_symbol, :reply_num_of_orders,
        :support_wallet_pay, :support_credits_pay, :credit_for_each_money, :enable_new_version, :max_branch_sliders,
        :award_credits_at_follow, :award_credits, :least_promotion_number, :domain)
      end
    end
end