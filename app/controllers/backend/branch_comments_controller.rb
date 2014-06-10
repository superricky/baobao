class Backend::BranchCommentsController < BackendApplicationController
  before_action :set_branch_comment, only: [:toggle_pub]

  # GET /branch_comments
  # GET /branch_comments.json
  def index
    @branch_comments = @current_shop.branch_comments.paginate(page: params[:page], :per_page => 25)
  end

  # PATCH/PUT /branch_comments/1
  # PATCH/PUT /branch_comments/1.json
  def toggle_pub
    @branch_comment.update(:can_pub => !@branch_comment.can_pub)
    redirect_to backend_shop_branch_comments_path(@current_shop.slug), notice: 'Branch comment was successfully updated.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_branch_comment
      @branch_comment = @current_shop.branch_comments.find(params[:id])
    end
end
