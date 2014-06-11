#encoding: utf-8
class Mobile::ProductsController < MobileApplicationController
  before_action :current_special_off, only: [:show]
  before_action :set_cart_id, only: [:show]
  before_action :load_entities, only: [:list, :categories, :search]

  include ProductsHelper

  def list
    impressionist(@current_branch, '',  unique: [:controller_name, :action_name, :session_hash, :user_id])
    @slides = @current_branch.product_sliders
  end

  def show
    @product = @current_branch.products.find params[:id]
    cart = @current_branch.carts.find(current_cart.id)
    line_item = cart.line_items.select{|l| l.product_id == @product.id}.first
    @quantity = line_item.quantity if line_item
  end

  def categories
    @categories = @current_branch.categories.where(category_id: 0).includes(:categories).includes(:products).group("categories.id")
  end

  def search
  end

  private
    def load_entities
      current_special_off
      set_cart_id
      if @current_shop.enable_new_version
        redirect_to client_new_client_root_path(@current_shop.slug)
        return
      end
      if params[:category].present? && params[:category].to_i > 0
        @products = @current_branch.products_online.joins(:categories).where("categories.id = ?", params[:category])
      elsif params[:keyword].present?
        @products = @current_branch.products_online.where("name like ?", "%#{params[:keyword]}%")
      else
        @products = @current_branch.products_online
      end
      @cart = @current_branch.carts.find(current_cart.id)
      @current_user.update_attributes(:last_login_ip => request.remote_ip)
    end
end
