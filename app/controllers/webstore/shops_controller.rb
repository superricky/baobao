class Webstore::ShopsController < WebstoreApplicationController
  def show
    impressionist(@current_shop, '',  unique: [:controller_name, :action_name, :session_hash, :user_id])
    respond_to do |format|
      format.json {}
      format.html {}
    end
  end
end