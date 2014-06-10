class WebstoreApplicationController < ApplicationController
  skip_before_action :configure_permitted_parameters
  skip_before_action :set_shop_id
  skip_before_action :check_shop_id
  skip_before_action :check_current_branch
  skip_before_action :check_branch_expired
  skip_before_action :global_request_logging
  skip_before_action :set_controller_name_params

  before_action :set_webstore_shop_and_branch
  #layout "webstore/application"
  layout "webstore/webstore"
end
