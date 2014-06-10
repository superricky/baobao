module Webstore::CartHelper
  def login_or_order_url
    current_member.present? ? "javascript:void(0);" : [webstore_login_path(@current_shop), callback_path].join("?")
  end

  def callback_path
    URI.encode_www_form({callback: request.url})
  end
end