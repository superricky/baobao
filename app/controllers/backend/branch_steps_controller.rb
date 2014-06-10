#encoding: utf-8
class Backend::BranchStepsController < BackendApplicationController
  include Wicked::Wizard
  before_action :set_branch
  skip_load_and_authorize_resource
  authorize_resource :class => false
  prepend_before_filter :set_steps

  steps :branch_info, :detail_info, :awards, :delivery_setting, :order_setting, :scrachpad_setting

  def show
    case step
    when :delivery_setting
      unless @branch.has_delivery_type?
        skip_step
      end
    end
    render_wizard
  end

  def update
    if params[:branch]
      @branch.supported_order_types = params[:branch][:supported_order_types].nil? ?
        @branch.supported_order_types : params[:branch][:supported_order_types].select{|type| Order::order_types_array.index(type).present? }.join(',')
      if params[:id] == "scrachpad_setting"
        @branch.supported_scratchpad_order_types = params[:branch][:supported_scratchpad_order_types].nil? ?
          nil : params[:branch][:supported_scratchpad_order_types].select{|type| Order::order_types_array.index(type).present? }.join(',')
      else
        @branch.supported_scratchpad_order_types = params[:branch][:supported_scratchpad_order_types].nil? ?
          @branch.supported_scratchpad_order_types : params[:branch][:supported_scratchpad_order_types].select{|type| Order::order_types_array.index(type).present? }.join(',')
      end
      if params[:id] == "order_setting"
        @branch.supported_send_sms_order_types = params[:branch][:supported_send_sms_order_types].nil? ?
          nil : params[:branch][:supported_send_sms_order_types].select{|type| Order::order_types_array.index(type).present? }.join(',')
      else
        @branch.supported_send_sms_order_types = params[:branch][:supported_send_sms_order_types].nil? ?
          @branch.supported_send_sms_order_types : params[:branch][:supported_send_sms_order_types].select{|type| Order::order_types_array.index(type).present? }.join(',')
      end
      @branch.update_attributes(branch_params.except(:supported_order_types, :supported_scratchpad_order_types, :supported_send_sms_order_types))
    elsif params[:id] == "awards"
      skip_step
    end
    render_wizard @branch
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
      flash[:notice] = t("Branch was successfully setted")
      backend_shop_branch_path(@current_shop, @branch)
    end

    def set_branch
      @branch = @current_shop.branches.find(params[:branch_id])
    end

    def branch_params
      if params[:branch]
        if @current_account.is_admin? or @current_account.is_boss?
          params.require(:branch).permit(:name, :is_open, :service_period_start, :service_period_end,
            :expiration_time, :notice, :telephone, :address, :zip_code, :latitude, :longitude, :introduction,
            :use_min_order_charge, :min_order_charge, :non_service_order_charge, :delivery_radius, :delivery_radius_txt, :image, :rect_image,
            :charge_method, :left_order_count, :notify_new_order, :use_sms, :max_sms_count, :use_sms_validation, :sms_to,
            :use_scrachpad, :first_prize_possibility, :second_prize_possibility, :third_prize_possibility, :terms, :fixed_delivery_time,
            :first_prize, :second_prize, :third_prize, :no_prize, :valid_before, :min_charge_for_scratch, :max_scratch_times_in_day, :enabled_verify_service_periods,
            :min_order_time_gap, :check_stock, :separate_notice_of_praise_and_new_order ,:product_list_style, :brand_chain_id, :allow_remind_order_msg, :branch_type_id,:supported_order_types => [],
            :supported_scratchpad_order_types => [], :zone_ids => [], :account_ids =>[], :supported_send_sms_order_types =>[], awards_attributes: [:id, :name, :description, :_destroy],
            delivery_zones_attributes: [:id, :zone_name, :charge, :_destroy], service_periods_attributes: [:id, :service_period_start, :service_period_end, :_destroy],
            delivery_times_attributes: [:id, :delivery_time_start, :delivery_time_end, :time_advance ,:_destroy])
        elsif @current_account.is_worker?
          params.require(:branch).permit(:name, :is_open, :service_period_start, :service_period_end, :notice, :telephone, :address,
            :zip_code, :latitude, :longitude, :introduction, :use_min_order_charge, :min_order_charge,
            :non_service_order_charge, :delivery_radius, :delivery_radius_txt, :image, :rect_image, :notify_new_order,:use_sms, :use_sms_validation, :sms_to,
            :use_scrachpad, :first_prize_possibility, :second_prize_possibility, :third_prize_possibility,:terms, :fixed_delivery_time,
            :first_prize, :second_prize, :third_prize, :no_prize, :valid_before, :min_charge_for_scratch, :max_scratch_times_in_day, :allow_remind_order_msg, :enabled_verify_service_periods,
            :min_order_time_gap, :check_stock,:product_list_style, :branch_type_id, :supported_send_sms_order_types =>[], awards_attributes: [:id, :name, :description, :_destroy], :zone_ids => [],:supported_order_types => [],
            :supported_scratchpad_order_types => [],  delivery_zones_attributes: [:id, :zone_name, :charge, :_destroy], service_periods_attributes: [:id, :service_period_start, :service_period_end, :_destroy],
            delivery_times_attributes: [:id, :delivery_time_start, :delivery_time_end, :time_advance ,:_destroy])
        end
      end
    end
end