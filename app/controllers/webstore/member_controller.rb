class Webstore::MemberController < WebstoreApplicationController
  before_action :authenticate_member!

  def show
    @member = current_member
  end

  def update
    @member = current_member
    unless @member.update_without_password member_params
      @member.password = nil
      render :status=>:bad_request
    else
      render 'show'
    end
  end

  private
    def member_params
      params[:member][:password] = current_member.password
      params.require(:member).permit(:name, :phone, :default_address, :password)
    end
end
