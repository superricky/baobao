#encoding: utf-8
class Webstore::Members::SessionsController < Devise::SessionsController
  skip_before_action :configure_permitted_parameters
  skip_before_action :set_shop_id
  skip_before_action :check_shop_id
  skip_before_action :check_current_branch
  skip_before_action :check_branch_expired
  skip_before_action :global_request_logging

  before_action :set_webstore_shop_and_branch
  respond_to :json
  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    sign_in(resource_name, resource)
    render :status => 200,
           :json => { :success => true,
                      :info => "登录成功",
                      :member => current_member
           }
  end

  def destroy
    warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    sign_out
    render :status => 200,
           :json => { :success => true,
                      :info => "退出成功",
           }
  end

  def failure
    render :status => :bad_request,
           :json => { :success => false,
                      :info => "登录失败，请仔细检查用户名或密码"
           }
  end

  def show_current_member
    warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    render :status => 200,
           :json => { :success => true,
                      :info => "当前用户信息",
                      :member => current_member
           }

  end
end
