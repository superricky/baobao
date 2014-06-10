class Backend::EventsController < BackendApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /events
  # GET /events.json
  def index
    @unmatch_event = @current_shop.events.unmatch_event.first
    @keyword_autoreply_events = @current_shop.events.keyword_autoreply_events
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @material = @event.material
  end

  # GET /events/new
  def new
    @event = @current_shop.events.build(material_id: params[:material_id])
    respond_to do |format|
      format.js
      format.html
    end
  end

  def unmatch_message
    @unmatch_event = @current_shop.events.unmatch_event.first
    @current_shop.update_attributes(enable_unrecognized_reply_message: params[:enable_unrecognized_reply_message])
    respond_to do |format|
      format.js
    end
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = @current_shop.events.build(event_params.except(:material_id))
    @material = @current_shop.materials.find(event_params[:material_id]) rescue nil
    if @material
      @event.material = @material
    elsif Event::SYSTEM_KEY.map{|key| key[1]}.include? event_params[:material_id]
      @event.is_system_keyword = true
      @event.system_keyword = event_params[:material_id].gsub(Event::KEY_PREFIX, "")
    end
    respond_to do |format|
      if @event.save
        format.js
        format.html { redirect_to backend_shop_events_path(@current_shop.slug), notice: t('Event was successfully created.') }
        format.json { render action: 'show', status: :created, location: @event }
      else
        format.js
        format.html { render action: 'new' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    @material = @current_shop.materials.find(event_params[:material_id]) rescue nil
    if @material
      @event.material = @material
      @event.is_system_keyword = false
      @event.system_keyword = nil
    elsif Event::SYSTEM_KEY.map{|key| key[1]}.include? event_params[:material_id]
      @event.material = nil
      @event.is_system_keyword = true
      @event.system_keyword = event_params[:material_id].gsub(Event::KEY_PREFIX, "")
    end
    respond_to do |format|
      if @event.update(event_params.except(:material_id))
        format.html { redirect_to backend_shop_events_path(@current_shop.slug), notice: t('Event was successfully updated.') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @material = @event.material
    @event.destroy
    respond_to do |format|
      format.html { redirect_to backend_shop_events_url }
      format.js
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = @current_shop.events.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:event, :event_key, :material_id)
    end
end
