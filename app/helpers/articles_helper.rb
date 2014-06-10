#encoding: utf-8
module ArticlesHelper
  def is_edit?
    params[:action] == 'edit'
  end

  def is_create?
    params[:action] == 'create'
  end

  def is_update?
    params[:action] == 'update'
  end

  def get_article_url(article, index)
    if not article.pic_url.nil?
      article.pic_url
    elsif not article.image.nil?
      if index == 0
        article.image.medium.url
      else
        article.image.thumb.url
      end
    else
      ""
    end
  end

  def article_link_type_selsec_options
    [[link_type_translate(Article::ARTICLE_SHOW_LINK), Article::ARTICLE_SHOW_LINK],
      [link_type_translate(Article::SHOP_OR_BRANCH_LINK), Article::SHOP_OR_BRANCH_LINK],
      [link_type_translate(Article::OUTSIDE_THE_WEB_LINK), Article::OUTSIDE_THE_WEB_LINK]]
  end

  def link_type_translate(type)
    t "activerecord.attributes.article.link_types.#{type}"
  end

end
