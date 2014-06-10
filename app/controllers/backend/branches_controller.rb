class Backend::BranchesController < BackendApplicationController
  before_action :set_branch, only: [:show, :edit, :update, :destroy, :assign_account, :remove_account]

  # GET /branches
  # GET /branches.json
  def index
    if current_account.is_worker?
      @branches = current_account.branches.paginate(:page => params[:page], :per_page => 25)
    else
      @branches = @current_shop.all_branches.paginate(:page => params[:page], :per_page => 25)
    end
  end

  # GET /branches/1
  # GET /branches/1.json
  def show
  end

  def exchange_position
    @branches = @current_shop.base_branches
    if params[:branch_ids].size != 2
      logger.error "The branch going to exchange are: #{params[:branch_ids]}"
      @errors = "需要提供进行排序的商户"
    else
      updated_branches =  @branches.find(params[:branch_ids])
      @first_branch = updated_branches[0]
      @second_branch = updated_branches[1]
      position = @second_branch.position
      @second_branch.position = @first_branch.position
      @first_branch.position = position
      Branch.transaction do
          if not @first_branch.save
            @errors = @first_branch.errors.full_messages
            raise ActiveRecord::Rollback
          end
          if not @second_branch.save
            @errors = @second_branch.errors.full_messages
            raise ActiveRecord::Rollback
          end
      end
    end

    respond_to do |format|
      if @errors.nil?
        format.js {}
      else
        format.js {}
      end
    end
  end

  def assign_account
    if params[:account_ids].present?
      @branch.account_ids += params[:account_ids]
      flash[:notice] = "帐号分配成功"
    else
      flash[:error] = "请选择要分配的账户！"
    end
    redirect_to backend_shop_branch_accounts_path(@current_shop, @current_branch)
  end

  def remove_account
    account = @branch.accounts.find(params[:account_id]) rescue nil
    @branch.accounts.destroy(account) if account
    flash[:notice] = "移除成功!"
    redirect_to backend_shop_branch_accounts_path(@current_shop, @current_branch)
  end

  # GET /branches/new
  def new
    if @current_shop.branches_count >= @current_shop.max_branches_count
      flash[:error] =  t('You have no authories to create more branch.')
      redirect_to backend_shop_branches_path(@current_shop.slug)
    else
      @branch = @current_shop.branches.build
      @branch.expiration_time = Time.now + 1.month
    end
  end

  # GET /branches/1/edit
  def edit
  end

  # POST /branches
  # POST /branches.json
  def create
    if @current_shop.branches_count >= @current_shop.max_branches_count
      flash[:error] =  t('You have no authories to create more branch.')
      redirect_to backend_shop_branches_path(@current_shop.slug)
    else
      @branch = @current_shop.branches.build(branch_params.except(:supported_order_types, :supported_scratchpad_order_types, :supported_send_sms_order_types))
      @branch.supported_order_types = params[:branch][:supported_order_types].nil? ?
         nil: params[:branch][:supported_order_types].select{|type| Order::order_types_array.index(type).present? }.join(',')
      @branch.supported_scratchpad_order_types = params[:branch][:supported_scratchpad_order_types].nil? ?
         nil: params[:branch][:supported_scratchpad_order_types].select{|type| Order::order_types_array.index(type).present? }.join(',')
      @branch.supported_send_sms_order_types = params[:branch][:supported_send_sms_order_types].nil? ?
         nil: params[:branch][:supported_send_sms_order_types].select{|type| Order::order_types_array.index(type).present? }.join(',')
      #@branch = @current_shop.branches.build(branch_params)
      respond_to do |format|
        if @branch.save
          format.html { redirect_to backend_shop_branch_branch_steps_path(@current_shop.slug, @branch) + "/detail_info" }
          format.json { render action: 'show', status: :created, location: @branch }
        else
          format.html { render action: 'new' }
          format.json { render json: @branch.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /branches/1
  # PATCH/PUT /branches/1.json
  def update
    @branch.supported_order_types = params[:branch][:supported_order_types].nil? ?
         nil: params[:branch][:supported_order_types].select{|type| Order::order_types_array.index(type).present? }.join(',')
    @branch.supported_scratchpad_order_types = params[:branch][:supported_scratchpad_order_types].nil? ?
         nil: params[:branch][:supported_scratchpad_order_types].select{|type| Order::order_types_array.index(type).present? }.join(',')
    @branch.supported_send_sms_order_types = params[:branch][:supported_send_sms_order_types].nil? ?
         nil: params[:branch][:supported_send_sms_order_types].select{|type| Order::order_types_array.index(type).present? }.join(',')
    respond_to do |format|
      if @branch.update_attributes(branch_params.except(:supported_order_types, :supported_scratchpad_order_types, :supported_send_sms_order_types))
        format.html { redirect_to backend_shop_branch_path(@current_shop.slug, @branch), notice: t('Branch was successfully updated.') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @branch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /branches/1
  # DELETE /branches/1.json
  def destroy
    @branch.destroy
    respond_to do |format|
      format.html { redirect_to backend_shop_branches_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_branch
    @branch = @current_shop.branches.find(params[:id])
    @current_branch = @branch
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def branch_params

    if @current_account.is_admin? or @current_account.is_boss?
      params.require(:branch).permit(:name, :is_open, :service_period_start, :service_period_end,
        :expiration_time, :notice, :telephone, :address, :zip_code, :latitude, :longitude, :introduction,
        :use_min_order_charge, :min_order_charge, :non_service_order_charge, :delivery_radius, :delivery_radius_txt, :image, :rect_image,
        :charge_method, :left_order_count, :notify_new_order, :use_sms, :max_sms_count, :use_sms_validation, :sms_to,
        :use_scrachpad, :first_prize_possibility, :second_prize_possibility, :third_prize_possibility,:terms, :enabled_verify_service_periods,
        :first_prize, :second_prize, :third_prize, :no_prize, :valid_before, :min_charge_for_scratch, :max_scratch_times_in_day,
        :min_order_time_gap, :check_stock, :separate_notice_of_praise_and_new_order ,:product_list_style, :brand_chain_id, :branch_type_id,:supported_order_types => [],
        :supported_scratchpad_order_types => [], :zone_ids => [], :account_ids =>[], :supported_send_sms_order_types =>[], awards_attributes: [:id, :name, :description, :_destroy],
        delivery_zones_attributes: [:id, :zone_name, :charge, :_destroy], service_periods_attributes: [:id, :service_period_start, :service_period_end, :_destroy])
    elsif @current_account.is_worker?
      params.require(:branch).permit(:name, :is_open, :service_period_start, :service_period_end, :notice, :telephone, :address,
        :zip_code, :latitude, :longitude, :introduction, :use_min_order_charge, :min_order_charge,
        :non_service_order_charge, :delivery_radius, :delivery_radius_txt, :image, :rect_image, :notify_new_order,:use_sms, :use_sms_validation, :sms_to,
        :use_scrachpad, :first_prize_possibility, :second_prize_possibility, :third_prize_possibility,:terms, :enabled_verify_service_periods,
        :first_prize, :second_prize, :third_prize, :no_prize, :valid_before, :min_charge_for_scratch, :max_scratch_times_in_day,
        :min_order_time_gap, :check_stock,:product_list_style, :branch_type_id, :supported_send_sms_order_types =>[], awards_attributes: [:id, :name, :description, :_destroy], :zone_ids => [],:supported_order_types => [],
        :supported_scratchpad_order_types => [],  delivery_zones_attributes: [:id, :zone_name, :charge, :_destroy], service_periods_attributes: [:id, :service_period_start, :service_period_end, :_destroy])
    end
  end
end
