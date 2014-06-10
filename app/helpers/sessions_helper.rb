#encoding: utf-8
module SessionsHelper
  # def sign_in(account)
  #   cookies.permanent[:remember_token] = account.remember_token
  #   self.current_account = account
  # end

  # def current_account=(account)
  #   @current_account = account
  # end

  # def current_account
  #   @current_account||= Account.find_by_remember_token(cookies[:remember_token])
  # end

  def current_account?(account)
    account == current_account
  end

  # def signed_in?
  #   !current_account.nil?
  # end

  # def sign_out
  #   logger.info "account #{current_account.login_id unless current_account.nil?} will be signout"
  #   self.current_account = nil
  #   cookies.delete(:remember_token)
  # end

  def redirect_back_or(default)
    unless session[:return_to].nil?
      redirect_to session[:return_to]
      session.delete(:return_to)
    else
      if default.is_admin?
        redirect_to default
      elsif default.branch_id.nil?
        redirect_to dashboard_backend_shop_path(default.shop.slug)
      else
        redirect_to backend_shop_branch_orders_path(default.shop.slug, default.branch)
      end
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end
end
