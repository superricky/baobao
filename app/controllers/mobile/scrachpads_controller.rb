class Mobile::ScrachpadsController < MobileApplicationController
  before_filter :set_cart_id
  before_action :set_scrachpad, only: [:show, :open]

  # GET /scrachpads
  # GET /scrachpads.json
  def index
    @scrachpads = @current_user.scrachpads
  end

  # GET /scrachpads/1
  # GET /scrachpads/1.json
  def show
  end

  # PATCH/PUT /scrachpads/1
  # PATCH/PUT /scrachpads/1.json
  def open
    respond_to do |format|
      @scrachpad.update_attributes(:is_opened=> true);
      format.json { head :no_content  }
    end
  end

  # DELETE /scrachpads/1
  # DELETE /scrachpads/1.json
  def destroy
    @scrachpad = @current_user.scrachpads.find(params[:id])
    @scrachpad.destroy if @scrachpad.present?
    respond_to do |format|
      format.html { redirect_to mobile_shop_branch_scrachpads_url(@current_shop.slug, @current_branch) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scrachpad
      @scrachpad = @current_user.scrachpads.with_deleted.find(params[:id])
    end
end
