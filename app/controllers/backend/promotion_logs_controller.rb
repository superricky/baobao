#encoding:utf-8
class Backend::PromotionLogsController < BackendApplicationController

  def index
    @articles = @current_shop.articles.promotion_articles
  end

  def article_promotion
    @article = @current_shop.articles.promotion_articles.find(params[:article_id])
    @groups = Hash[@current_shop.articles.promotion_articles.find(params[:article_id]).promotion_logs.all.group_by{|p| [p.sharer, p.sharer_nickname]}.sort_by{|k, v| v.length}.reverse]
  end

  def promotion_user
    if params[:source] == "site"
      @user = @current_shop.users.find_by(fake_user_name: params[:fake_user_name])
    elsif params[:source] == "weixin"
      @wx_user_info = User.user_info_from_wx(@current_shop, params[:fake_user_name])
    else
      @user = @current_shop.users.find_by(fake_user_name: params[:fake_user_name])
      @wx_user_info = User.user_info_from_wx(@current_shop, params[:fake_user_name])
    end

    respond_to do |format|
      format.js
    end
  end
end