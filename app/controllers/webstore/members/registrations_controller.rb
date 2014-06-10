class Webstore::Members::RegistrationsController < Devise::RegistrationsController
  before_action :set_webstore_shop_and_branch
  respond_to :json

  def after_sign_in_path_for(resource)
    webstore_member_show_path @current_shop
  end

  def after_inactive_sign_up_path_for(resource)
    "#{webstore_welcome_path resource.shop}#/member/login"
  end

  def update
    resource_name = :member
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    if params[:member][:password].present? && update_resource(resource, account_update_params)
      yield resource if block_given?
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, :bypass => true
      if resource.valid?
        render 'webstore/member/show'
      else
        render :status=>:bad_request, :json=> {
          :errors => resource.errors.full_messages
        }
      end
    else
      clean_up_passwords resource
      render :status=>:bad_request, :json=> {
        :errors => resource.errors.full_messages
      }
    end
  end

  def sign_up_params
    params[:member][:shop_id] = @current_shop.id
    params[:member][:host] = request.host
    params.require(:member).permit(:name, :email, :password, :password_confirmation, :shop_id, :host)
  end
end
