#encoding:utf-8
module MessagesHelper
  def get_absolute_url_for_path(path)
    if path.nil?
      "#{request.protocol}#{request.host_with_port}"
    elsif path =~ /\Ahttp:\/\/.+\Z/i
      path
    else
      "#{request.protocol}#{request.host_with_port}/#{path}"
    end
  end

  def welcome_msg
    if @current_shop.welcome_msg.nil? or @current_shop.welcome_msg.strip.empty?
      "#{welcome_msg_unchanged}"
    else
      "#{@current_shop.welcome_msg}"
    end
  end

  def wrap_branch_new_client(shop, branch)
    "#{wrap_url_with_additional_info(client_weixinpay_url(shop.slug))}#product-list/branches/#{branch.id}"
  end

  def welcome_msg_unchanged
    site_config = SiteConfig.where(key:SiteConfig::SITECONFIG_WEIXIN_HELP_MSG).first_or_create(
      :display_name=>"帮助消息", :value_type=>"string", :value_s=>"以下是本微信公众账号的使用说明:\n回复0:获得使用帮助\n回复1:获得点餐链接\n回复2:获得当前的促销活动\n回复3:获得最近历史订单\n回复4:查询我的会员信息\n点击+发送位置:获得最近的商铺\n留言请发送'@+留言内容'")
    "亲爱的微信用户，您好！感谢您关注\"#{@current_shop.name if @current_shop.present?}\"的微信公众账号。#{site_config.value}"
  end
end