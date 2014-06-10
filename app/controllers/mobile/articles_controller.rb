#encoding: utf-8
class Mobile::ArticlesController < MobileApplicationController
  before_action :set_article, only: [:show]

  def show
    render layout: 'mobile/empty'
  end

  private
    def set_article
      @article = @current_shop.materials.find(params[:material_id]).articles.find(params[:id])
    end
end