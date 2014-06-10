class Backend::PostThreadLabelsController < BackendApplicationController
  before_action :set_post_thread_label, only: [:show, :edit, :update, :destroy]

  # GET /post_thread_labels
  # GET /post_thread_labels.json
  def index
    @post_thread_labels = PostThreadLabel.all
  end

  # GET /post_thread_labels/1
  # GET /post_thread_labels/1.json
  def show
  end

  # GET /post_thread_labels/new
  def new
    @post_thread_label = PostThreadLabel.new
  end

  # GET /post_thread_labels/1/edit
  def edit
  end

  # POST /post_thread_labels
  # POST /post_thread_labels.json
  def create
    @post_thread_label = PostThreadLabel.new(post_thread_label_params)

    respond_to do |format|
      if @post_thread_label.save
        format.html { redirect_to [:backend, @post_thread_label], notice: 'Post thread label was successfully created.' }
        format.json { render action: 'show', status: :created, location: @post_thread_label }
      else
        format.html { render action: 'new' }
        format.json { render json: @post_thread_label.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /post_thread_labels/1
  # PATCH/PUT /post_thread_labels/1.json
  def update
    respond_to do |format|
      if @post_thread_label.update(post_thread_label_params)
        format.html { redirect_to [:backend, @post_thread_label], notice: 'Post thread label was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @post_thread_label.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /post_thread_labels/1
  # DELETE /post_thread_labels/1.json
  def destroy
    @post_thread_label.destroy
    respond_to do |format|
      format.html { redirect_to backend_post_thread_labels_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post_thread_label
      @post_thread_label = PostThreadLabel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_thread_label_params
      params.require(:post_thread_label).permit(:name)
    end
end
