class Backend::MenusController < BackendApplicationController
  before_action :set_menu, only: [:show, :edit, :update, :destroy]
  before_action :set_system_config
  include WechatUtils

  # GET /menus
  # GET /menus.json
  def index
    @root_menus = @system_config.menus.root_menus
  end

  # GET /menus/1
  # GET /menus/1.json
  def show
  end

  # GET /menus/new
  def new
    @menu = @system_config.menus.build({:parent_menu_id => params[:parent_menu_id]})
    @parent_menus_array = @system_config.menus.root_menus.map{|menu| [menu.name, menu.id]}
  end

  # GET /menus/1/edit
  def edit
    @parent_menus_array = get_other_top_menu
  end

  def async
    conn = connect_weixin
    access_token = fetch_weixin_access_token(conn, @system_config.appId, @system_config.appSecret)

    if access_token.nil?
      redirect_to backend_shop_system_config_menus_path(@current_shop.slug, @system_config), notice: t('Menu was unable to synchronized.')
      return
    end
    response = conn.post do |req|
      req.url "/cgi-bin/menu/create?access_token=#{access_token}"
      req.headers['Content-Type'] = 'application/json'
      req.body = as_menu_json.to_json.gsub!(/\\u([0-9a-z]{4})/) {|s| [$1.to_i(16)].pack("U")}||as_menu_json.to_json
    end
    logger.info response.to_json
    responseBody = ActiveSupport::JSON.decode(response.body).to_options
    logger.info responseBody[:errcode]
    if responseBody[:errcode] != 0
      logger.info responseBody[:errmsg]
      flash[:error] = responseBody[:errmsg]
      render
    end

  end

  def preview_json
    render json: as_menu_json.to_json.gsub!(/\\u([0-9a-z]{4})/) {|s| [$1.to_i(16)].pack("U")}||as_menu_json.to_json
  end

  # POST /menus
  # POST /menus.json
  def create
    material = @current_shop.materials.find(menu_params[:material_id]) rescue nil
    @menu = @current_shop.menus.build(menu_params.except(:material_id))

    if material
      @menu.material = material
    elsif Menu.reply_message(@system_config).map{|key| key[1]}.include? menu_params[:material_id]
      @menu.keyword = menu_params[:material_id].gsub(Event::KEY_PREFIX, "")
    end
    @system_config.menus << @menu
    @menus_array = @system_config.menus.map {|menu| [menu.name, menu.id]}

    respond_to do |format|
      if @menu.save
        format.html { redirect_to backend_shop_system_config_menu_path(@current_shop.slug,@system_config , @menu), notice: t('Menu was successfully created.') }
        format.json { render action: 'show', status: :created, location: @menu }
      else
        @parent_menus_array = @current_shop.menus.map {|menu| [menu.name, menu.id]}
        format.html { render action: 'new' }
        format.json { render json: @menu.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /menus/1
  # PATCH/PUT /menus/1.json
  def update
    material = @current_shop.materials.find(menu_params[:material_id]) rescue nil
    if material
      @menu.material = material
      @menu.keyword = nil
    elsif Menu.reply_message(@system_config).map{|key| key[1]}.include? menu_params[:material_id]
      @menu.keyword = menu_params[:material_id].gsub(Event::KEY_PREFIX, "")
      @menu.material = nil
    end
    respond_to do |format|
      if @menu.update(menu_params.except(:event_id))
        format.html { redirect_to backend_shop_system_config_menu_path(@current_shop.slug,@system_config, @menu), notice: t('Menu was successfully updated.') }
        format.json { head :no_content }
      else
        @parent_menus_array = get_other_top_menu
        format.html { render action: 'edit' }
        format.json { render json: @menu.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /menus/1
  # DELETE /menus/1.json
  def destroy
    if params[:delete] == "true"
      @menu.destroy
    else
      menus_to_delete = []
      unless @menu.submenus.empty?
        menus_to_delete += @menu.submenus
      end
      menus_to_delete << @menu
      @system_config.menus.delete(menus_to_delete)

      menus_to_destroy = menus_to_delete.select{|menu| menu.system_configs.empty?}
      unless menus_to_destroy.empty?
        Menu.destroy(menus_to_destroy)
      end
    end
    respond_to do |format|
      format.html { redirect_to backend_shop_system_config_menus_url(@current_shop, @system_config) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_menu
      set_system_config
      @menu = @system_config.menus.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def menu_params
      params.require(:menu).permit(:name, :event_type, :material_id, :url, :parent_menu_id, :menu_type)
    end

    def get_other_top_menu
      @system_config.menus.root_menus.where('id <> ?', params[:id]).map {|menu| [menu.name, menu.id]}
    end


    def as_menu_json
      @menus_array = @system_config.menus.root_menus
      json = {:button => []}
      @menus_array.each do |menu|
        json[:button] << as_json(menu)
      end
      json
    end

    def as_json(menu)
      json = {:name => menu.name }
      submenus = @system_config.menus.where(:parent_menu=>menu)
      if not submenus.empty?
        json[:sub_button] = [];
        submenus.each do |submenu|
          json[:sub_button] << as_json(submenu)
        end
      else
        json[:type] = menu.event_type
        if( menu.event_type == Menu::EVENTTYPES[0])
          json[:key] = menu.key_value
        else
          json[:url] = menu.url
        end
      end
      json
    end

    def set_system_config
      @system_config = @current_shop.system_configs.find(params[:system_config_id]) rescue nil
    end

end
