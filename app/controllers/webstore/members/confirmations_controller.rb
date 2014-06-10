class Webstore::Members::ConfirmationsController < Devise::ConfirmationsController
  skip_before_action :configure_permitted_parameters
  skip_before_action :set_shop_id
  skip_before_action :check_shop_id
  skip_before_action :check_current_branch
  skip_before_action :check_branch_expired
  skip_before_action :global_request_logging

  before_action :set_webstore_shop_and_branch
  layout "webstore/application"

  def after_confirmation_path_for(resource_name, resource)
    "#{webstore_welcome_path resource.shop}#/member/login?events=confirm_success"
  end
end
