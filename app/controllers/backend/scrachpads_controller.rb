class Backend::ScrachpadsController < BackendApplicationController
  before_action :set_scrachpad, only: [:show]

  def branch_index
    @q = @current_branch.scrachpads.with_deleted.order('created_at DESC').search(params[:q])
    @scrachpads = @q.result(distinct: true).paginate(:page => params[:page], :per_page => 50)
  end

  def search
    branch_index
    render "branch_index"
  end

  def deactivate
    @scrachpad = @current_branch.scrachpads.find(params[:id])
    unless @scrachpad.is_used
      @scrachpad.update_attributes(:is_used => true, :used_time=>Time.now)
    end
    respond_to do |format|
      format.js {}
    end
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scrachpad
      @scrachpad = @current_user.scrachpads.with_deleted.find(params[:id])
    end
end
