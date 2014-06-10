class Backend::FormElementsController < BackendApplicationController
  before_action :set_form_element, only: [:show, :edit, :update, :destroy]

  # GET /form_elements
  # GET /form_elements.json
  def index
    @form_elements = @current_branch.form_elements.order("form_elements.sequence")
  end

  # GET /form_elements/1
  # GET /form_elements/1.json
  def show
  end

  def save_sequence
    if params[:sequence] && params[:sequence].present?
      params[:sequence].split(",").each_with_index do |id, s|
        @current_branch.form_elements.find_by_id_and_shop_id(id, @current_shop.id).update_attribute :sequence, s
      end
    end
  end

  # GET /form_elements/new
  def new
    @form_element = FormElementText.new
    render "new"
  end

  def new_select
    @form_element = FormElementSelect.new
    render "new"
  end

  # GET /form_elements/1/edit
  def edit
  end

  # POST /form_elements
  # POST /form_elements.json
  def create
    @form_element = @current_branch.form_elements.build(form_element_params)

    respond_to do |format|
      if @form_element.save
        @form_elements = @current_branch.form_elements
        format.js
      else
        render "new"
      end
    end
  end

  # PATCH/PUT /form_elements/1
  # PATCH/PUT /form_elements/1.json
  def update
    respond_to do |format|
      if @form_element.update(form_element_params)
        index
        format.js
        format.json { head :no_content }
      else
        render "edit"
        format.json { render json: @form_element.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /form_elements/1
  # DELETE /form_elements/1.json
  def destroy
    @form_element.destroy
    index
    respond_to do |format|
      format.js
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_form_element
      @form_element = FormElement.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def form_element_params
      type = params[:type].underscore.to_sym
      hook_data = {branch_id: @current_branch.id, shop_id: @current_shop.id}
      params[type].merge! hook_data
      params[type][:form_elements_attributes].keys.each do |key|
        params[type][:form_elements_attributes][key].merge! hook_data.merge({type: FormElementOption.name})
      end if params[type][:form_elements_attributes].present?
      params.require(type).permit(:type, :statement, :need, :placeholder, :regex, :shop_id, :sequence, :form_element_id, :branch_id, :deleted_at, form_elements_attributes: [:id, :need, :placeholder, :form_element_id, :_destroy, :type, :statement, :sequence, :shop_id, :branch_id])
    end
end
