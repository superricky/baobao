#encoding: utf-8
class Backend::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters, :only => [:create]
  layout 'login'

  def after_sign_up_path_for(resource)
    backend_login_path
  end

  def new
    super
  end

  def create
    build_resource(sign_up_params)
    @shop = Shop.new(name: sign_up_params[:shop_attributes][:name],
      aid: sign_up_params[:shop_attributes][:aid],
      slug: sign_up_params[:login_id],
      telephone: sign_up_params[:phone],
      expiration_time: DateTime.now + 7.day)
    resource.shop = @shop
    resource.captcha_valid = captcha_valid?(sign_up_params[:captcha])
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{session[:captcha]}|#{resource.captcha_valid}|#{sign_up_params[:captcha]}"
    if resource.save
      resource.shop.update_attribute :enable_new_version, false
      resource.add_role Account::ACCOUNTYPE_SHOP_BOSS
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end


  private

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:login_id, :email, :password, :password_confirmation ,:phone, :name, :captcha, :shop_attributes=>[:name, :aid]) }
    end
end