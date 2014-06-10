module AccountsHelper
  def get_accounts_form_path
    if @account.new_record?
      get_accounts_path
    else
      get_account_path(@account)
    end
  end

  def get_accounts_path
    if @current_shop.nil?
      backend_accounts_path
    elsif @current_branch.nil?
      backend_shop_accounts_path(@current_shop.slug)
    else
      backend_shop_branch_accounts_path(@current_shop.slug, @current_branch)
    end
  end

  def get_account_path(account)
    if @current_shop.nil?
        backend_account_path(account)
      elsif @current_branch.nil?
        backend_shop_account_path(@current_shop.slug, account)
      else
        backend_shop_branch_account_path(@current_shop.slug, @current_branch, account)
      end
  end

  def get_edit_account_path(account)
    "#{get_account_path(account)}/edit"
  end

  def get_edit_password_account_path(account)
    "#{get_account_path(account)}/edit_password"
  end

  def get_update_password_account_path(account)
    "#{get_account_path(account)}/update_password"
  end

  def get_reset_password_account_path(account)
    "#{get_account_path(account)}/reset_password"
  end

  def get_show_my_account_path
    @current_account = current_account
    if @current_account.is_admin?
      show_my_account_backend_accounts_path
    elsif @current_account.is_boss?
      show_my_account_backend_shop_accounts_path(@current_shop.slug)
    elsif @current_account.is_worker?
      show_my_account_backend_shop_branch_accounts_path(@current_shop.slug, @current_branch)
    end
  end

  def get_config_my_account_path
    if @current_account.is_admin?
      config_my_account_backend_accounts_path
    elsif @current_account.is_boss?
      config_my_account_backend_shop_accounts_path(@current_shop.slug)
    elsif @current_account.is_worker?
      config_my_account_backend_shop_branch_accounts_path(@current_shop.slug, @current_branch)
    end
  end

  def get_update_my_account_path
    if @current_account.is_admin?
      update_my_account_backend_accounts_path
    elsif @current_account.is_boss?
      update_my_account_backend_shop_accounts_path(@current_shop.slug)
    elsif @current_account.is_worker?
      update_my_account_branch_backend_accounts_path(@current_shop.slug, @current_branch)
    end
  end

  def get_edit_my_password_path
    if @current_account.is_admin?
      edit_my_password_backend_accounts_path
    elsif @current_account.is_boss?
      edit_my_password_backend_shop_accounts_path(@current_shop.slug)
    elsif @current_account.is_worker?
      edit_my_password_backend_shop_branch_accounts_path(@current_shop.slug, @current_branch)
    end
  end

  def get_update_my_password_path
    if @current_account.is_admin?
      update_my_password_backend_accounts_path
    elsif @current_account.is_boss?
      update_my_password_backend_shop_accounts_path(@current_shop.slug)
    elsif @current_account.is_worker?
      update_my_password_backend_shop_branch_accounts_path(@current_shop.slug, @current_branch)
    end
  end

  def is_admin_or_boss?(account)
    account.is_admin? or account.is_boss?
  end


end
