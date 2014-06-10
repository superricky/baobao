#encoding: utf-8

module UsersHelper
  def get_user_path(user)
    if @current_branch.present?
      backend_shop_branch_user_path(@current_shop.slug, @current_branch, user)
    else
      backend_shop_user_path(@current_shop.slug, user)
    end
  end

  def get_users_path
    if @current_branch.present?
      backend_shop_branch_users_path(@current_shop.slug, @current_branch)
    else
      backend_shop_users_path(@current_shop.slug)
    end
  end

  def get_block_user_path(user)
    if @current_branch.present?
      block_backend_shop_branch_user_path(@current_shop.slug, @current_branch, user)
    else
      block_backend_shop_user_path(@current_shop.slug, user)
    end
  end

  def get_edit_user_path(user)
    if @current_branch.present?
      edit_backend_shop_branch_user_path(@current_shop.slug, @current_branch, user)
    else
      edit_backend_shop_user_path(@current_shop.slug, user)
    end
  end
end