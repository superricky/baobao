#encoding: utf-8;
module Webstore::ApplicationHelper

  def set_cart_cookie
    cookies[:cart].present? ? "$.cookie('cart', #{cookies[:cart].split(",")})" : "$.cookie('cart', [])"
  end

  def price_view(price)
    price.to_i == price.to_f ? price.to_i : price
  end

  def price_with_currency_tag(price)
    "<span class='currency'>￥</span>#{price_view price}".html_safe
  end

  def holderjs(w = 100, h = 100)
    "holder.js/#{w}x#{h}/text::)/#efefef:#000".html_safe
  end
end
