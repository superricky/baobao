class Backend::PostsController < BackendApplicationController
  before_action :set_post_thread

  # GET /post_threads/1
  # GET /post_threads/1.json
  def show
  end

  # GET /post_threads/new
  def new
    @post = @post_thread.posts.build
    respond_to do |format|
      format.js {}
    end
  end
  # POST /post_threads
  # POST /post_threads.json
  def create
    @post = @post_thread.posts.build(post_params)
    @post.account = current_account
    respond_to do |format|
      if @post.save
        format.js {}
      else
        format.js { render 'error'}
      end
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post_thread
      @post_thread = PostThread.find(params[:post_thread_id])
    end

    def set_post
      @post = @post_thread.posts.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:content)
    end
end
