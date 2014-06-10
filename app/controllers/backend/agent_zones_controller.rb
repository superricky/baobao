class Backend::AgentZonesController < BackendApplicationController
  before_action :set_agent_zone, only: [:show, :edit, :update, :destroy]

  # GET /agent_zones
  # GET /agent_zones.json
  def index
    @agent_zones = AgentZone.root_agent_zones
  end

  # GET /agent_zones/1
  # GET /agent_zones/1.json
  def show
  end

  # GET /agent_zones/new
  def new
    @agent_zone = AgentZone.new
  end

  # GET /agent_zones/1/edit
  def edit
  end

  # POST /agent_zones
  # POST /agent_zones.json
  def create
    @agent_zone = AgentZone.new(agent_zone_params)

    respond_to do |format|
      if @agent_zone.save
        format.html { redirect_to [:backend,@agent_zone], notice: 'Agent zone was successfully created.' }
        format.json { render action: 'show', status: :created, location: @agent_zone }
      else
        format.html { render action: 'new' }
        format.json { render json: @agent_zone.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /agent_zones/1
  # PATCH/PUT /agent_zones/1.json
  def update
    respond_to do |format|
      if @agent_zone.update(agent_zone_params)
        format.html { redirect_to [:backend,@agent_zone], notice: 'Agent zone was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @agent_zone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /agent_zones/1
  # DELETE /agent_zones/1.json
  def destroy
    @agent_zone.destroy
    respond_to do |format|
      format.html { redirect_to backend_agent_zones_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_agent_zone
      @agent_zone = AgentZone.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def agent_zone_params
      params.require(:agent_zone).permit(:name, :parent_agent_zone_id)
    end
end
