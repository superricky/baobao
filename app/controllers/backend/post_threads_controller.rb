class Backend::PostThreadsController < BackendApplicationController
  before_action :set_post_thread, only: [:show, :edit, :update, :destroy, :request_for_feature, :toggle_publish, :close_post]


  # GET /post_threads
  # GET /post_threads.json
  def index
    @post_threads = PostThread.viewable(current_account)
  end

  # GET /post_threads/1
  # GET /post_threads/1.json
  def show
    if current_account.is_admin? and @post_thread.current_state == :new
      @post_thread.open!
    end
    @post_thread.posts
  end

  def close_post
    @post_thread.close!
    redirect_to [:backend, @post_thread]
  end

  def toggle_publish
    @post_thread.toggle_publish
    redirect_to [:backend, @post_thread]
  end

  def request_for_feature
    @post_thread.request
    respond_to do |format|
      format.js {}
    end
  end

  # GET /post_threads/new
  def new
    @post_thread = current_account.post_threads.build
  end

  # GET /post_threads/1/edit
  def edit
  end

  # POST /post_threads
  # POST /post_threads.json
  def create
    @post_thread = current_account.post_threads.build(post_thread_params)
    @post_thread.post_thread_label_ids = post_thread_params[:post_thread_label_ids][1..-1]

    respond_to do |format|
      if @post_thread.save
        format.html { redirect_to [:backend, @post_thread], notice: 'Post thread was successfully created.' }
        format.json { render action: 'show', status: :created, location: @post_thread }
      else
        format.html { render action: 'new' }
        format.json { render json: @post_thread.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /post_threads/1
  # PATCH/PUT /post_threads/1.json
  def update
    @post_thread.post_thread_label_ids = post_thread_params[1..-1]
    respond_to do |format|
      if @post_thread.update(post_thread_params)
        format.html { redirect_to [:backend, @post_thread], notice: 'Post thread was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @post_thread.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /post_threads/1
  # DELETE /post_threads/1.json
  def destroy
    @post_thread.destroy
    respond_to do |format|
      format.html { redirect_to backend_post_threads_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post_thread
      @post_thread = PostThread.viewable(current_account).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_thread_params
      params.require(:post_thread).permit(:title, :content, :post_thread_label_ids=>[])
    end
end
