#encoding: utf-8
class SystemMaterial
  include Rails.application.routes.url_helpers
  include WechatMessage

  def initialize(from_user_name, to_user_name, shop, user)
    @from_user_name = from_user_name
    @to_user_name = to_user_name
    @user = user
    @shop = shop
  end

  def build_message

  end

  def get_giving_credits_notice
    if @user.present? && @shop.award_credits_at_follow && @user.credits_logs.where(credit_log_type: CreditsLog::CREDITS_LOG_TYPE_FOLLOW).empty?
      @user.increment!(:credits, @shop.award_credits)
      @user.shop.increment!(:credits_given, @shop.award_credits)
      @user.create_credits_log(CreditsLog::CREDITS_LOG_TYPE_FOLLOW, @shop.award_credits, "首次关注获得积分")
      giving_notice = "\n\n谢谢您关注我们，#{@shop.award_credits}个积分将送给首次关注的您！"
    else
      nil
    end
  end

  def welcome_msg
    if @shop.welcome_msg.nil? or @shop.welcome_msg.strip.empty?
      "#{welcome_msg_unchanged}"
    else
      "#{@shop.welcome_msg}"
    end
  end

  def wrap_branch_new_client(branch)
    if @shop.show_detail_for_branch
      "#{wrap_url_with_additional_info(client_weixinpay_path(@shop.slug))}#branch-detail/branches/#{branch.id}"
    else
      "#{wrap_url_with_additional_info(client_weixinpay_path(@shop.slug))}#product-list/branches/#{branch.id}"
    end
  end

  def welcome_msg_unchanged
    site_config = SiteConfig.where(key:SiteConfig::SITECONFIG_WEIXIN_HELP_MSG).first_or_create(
      :display_name=>"帮助消息", :value_type=>"string", :value_s=>"以下是本微信公众账号的使用说明:\n回复0:获得使用帮助\n回复1:获得点餐链接\n回复2:获得当前的促销活动\n回复3:获得最近历史订单\n回复4:查询我的会员信息\n点击+发送位置:获得最近的商铺\n留言请发送'@+留言内容'")
    "亲爱的微信用户，您好！感谢您关注\"#{@shop.name if @shop.present?}\"的微信公众账号。#{site_config.value}"
  end

  def wrap_url_with_additional_info(url)
    appendStr = "fakeUserName=#{@user.fake_user_name}&&userId=#{@user.id}&&source=mp.weixin.qq.com"
    if url.nil? or url.empty?
    appendStr
    else
      uri = URI.parse(url)
      if uri.query.nil? or uri.query.empty?
      uri.query = appendStr
      else
        uri.query = uri.query+ "&&" +appendStr
      end
      uri.query += "&&uuid=#{SecureRandom.uuid}"
    uri.to_s
    end
  end

  def article_url(branch = nil)
    if branch.nil?
      @shop.enable_new_version? ?  wrap_url_with_additional_info(client_weixinpay_path(@shop.slug)) : wrap_url_with_additional_info(list_mobile_shop_branches_path(@shop.slug))
    else
      @shop.enable_new_version? ? wrap_branch_new_client(branch) : wrap_url_with_additional_info(list_mobile_shop_branch_products_path(@shop, branch))
    end
  end

  def get_generalize_notice
    system_config = @shop.system_configs.find_by(my_fake_id: @from_user_name)
    if system_config.present? && !system_config.gonghao_type
      generalize_notice = ""
      if system_config.be_verified
        @shop.events.get_generalize_events.each do |event|
          generalize_notice += "\"#{event.event_key}\" "
        end
        generalize_notice += "\n\n回复： " + generalize_notice + "得到推广链接 \n\n回复5：查看所有推广文章" if generalize_notice.present?
        generalize_notice += "\n\n回复6:获得推广二维码"
      end
    end
  end

end

class HelpSystemMaterial< SystemMaterial

  def build_message
    if @shop.default_reply_content_type == Shop::REPLY_CONTENT_TYPE_TEXT
      content = "#{welcome_msg} #{get_giving_credits_notice}"
      response_with_text_msg(@from_user_name, @to_user_name, content)
    elsif @shop.default_reply_content_type == Shop::REPLY_CONTENT_TYPE_NEWS
      if @shop.enable_new_version
        url = wrap_url_with_additional_info(client_weixinpay_path(@shop.slug))
        if @shop.active_branches.present? and @shop.branches.size == 1
          url = wrap_branch_new_client(@shop.active_branches.first)
        end
      else
        url = list_mobile_shop_branches_path(@shop.slug)
        if @shop.active_branches.present? and @shop.branches.size == 1
          url = list_mobile_shop_branch_products_path(@shop.slug, @shop.active_branches.first)
        end
        url = wrap_url_with_additional_info(url)
      end
      title = "#{@shop.name}感谢您的关注"
      description = "#{welcome_msg} #{get_giving_credits_notice} #{get_generalize_notice} \n\n点击进入>>>"
      articles = [Article.new(title: title, description: description, pic_url: @shop.image.medium.url, url: url )]
      response_with_news_msg(@from_user_name, @to_user_name, *articles)
    end
  end
end

class ShopSystemMaterial < SystemMaterial

  def build_message
    articles = []
    branches = @shop.active_branches.limit(9)
    if not branches.empty? and branches.size>1
      content = "欢迎关注#{@shop.name}，点我进入商户列表"
      articles << Article.new(title: content, description: '直接进入商户列表',pic_url: @shop.image.medium.url, url: article_url(nil))
      branches.each_with_index do |branch,index|
        articles << Article.new(title: branch.name, description: branch.introduction, pic_url: branch.image.thumb.url, url: article_url(branch))
     end
    elsif not branches.empty? and branches.size == 1
      content = "欢迎关注#{@shop.name},点击图片开始下单"
      branch = branches.first
      articles << Article.new(title: content, description: (branch.introduction||@shop.introduction), pic_url: @shop.image.medium.url, url: article_url(branch))
    else
      content = "该账号尚未建立商户"
      articles << Article.new(title: content, description: "直接进入商户列表", pic_url: @shop.image.medium.url, url: article_url(nil))
    end
    response_with_news_msg(@from_user_name, @to_user_name, *articles)
  end

end

class PromotionSystemMaterial < SystemMaterial

  def build_message
    articles = []
    branch_ids = @shop.active_branches.map(&:id)
    current_time = Time.now
    promotions = Promotion.where("branch_id in (?) and start_time <= ? and end_time > ?", branch_ids, current_time, current_time).order("updated_at DESC").limit(9)
    unless promotions.empty?
      content = "为您找到#{promotions.size}家商户促销活动"
      articles << Article.new(title: content, description: "直接进入商户列表", pic_url: @shop.image.medium.url, url: article_url(nil))
      promotions.each_with_index do |promotion,index|
        pic_url = promotion.image.thumb.url
        title = "商户\"#{promotion.branch.name}\"正在开展促销活动#{promotion.name}"
        url = wrap_url_with_additional_info(mobile_shop_branch_detail_special_off_path(@shop.slug, promotion.branch))
        articles << Article.new(title: title, description: promotion.description, pic_url: promotion.image.thumb.url, url: url)
      end
    else
      content = "当前没有商户正在开展促销活动"
      articles << Article.new(title: content, description: '直接进入商户列表', pic_url: @shop.image.medium.url, url: article_url(nil))
    end
    response_with_news_msg(@from_user_name, @to_user_name, *articles)
  end
end

class OrderSystemMaterial < SystemMaterial
  def build_message
    orders = User.find_by_fake_user_name(@to_user_name).get_orders_by_reply_orders_type.limit(8) rescue nil
    articles = []
    articles << Article.new(title: "历史订单", description: "", pic_url: @shop.image.medium.url ,url: article_url(nil))
    if orders && orders.size > 0
      orders.each do |order|
        articles << Article.new(title: "订购时间（#{order.created_at.strftime('%Y-%m-%d %H:%M:%S')}）", description: order.order_detail, url: (wrap_url_with_additional_info(client_order_path(@shop, order))))
      end
    else
      articles << Article.new(title: "对不起，没有历史订单", description: "下单后再来吧！")
    end
    response_with_news_msg(@from_user_name, @to_user_name, *articles)
  end
end

class VipUserSystemMaterial < SystemMaterial
  #vip user info: 4

  def build_message
    articles = []
    user = User.find_by_fake_user_name(@to_user_name)
    content = "尊敬的#{@shop.name}会员: \n\t会员编号:#{user.id}"
    if user.vip_no.present?
      content += "\n\tVIP会员卡号: #{user.vip_no}"
    end
    content +="\n\t姓名：#{user.name.present? ? user.name : '未知'}\n\t电话: #{user.phone.present? ? user.phone : '未知'}\n\t邮箱: #{user.email_address.present? ? user.email_address: '未知'}\n\t常用地址: #{user.default_address.present? ? user.default_address : '未知'}"
    content +="\n您在本店的订单数#{user.orders_count.present? ? user.orders_count : 0 }笔"
    title = "\n尊敬的会员#{user.name if user.name.present?},您的当前积分为#{user.credits}"
    articles << Article.new(title: title, description: content, pic_url: @shop.image.medium.url, url: article_url(nil))
    response_with_news_msg(@from_user_name, @to_user_name, *articles)
  end
end


class GeneralizeSystemMaterial < SystemMaterial
  #推广营销:5

  def build_message
    if @user.name.present?
      article_list = @shop.articles.promotion_articles
      if article_list.size == 1
        generalizes_position_system_material = GeneralizePositionSystemMaterial.new(@from_user_name, @to_user_name, @shop, @user)
        generalizes_position_system_material.set_passage(article_list.first)
        return generalizes_position_system_material.build_message
      elsif article_list.size > 1
        content = "编号\t\t\t文章标题\n" + article_list.map{|article| "#{article.id}\t\t\t#{article.title}"}.join("\n").to_s + "#{"\n\n输入(如: 5#1234, “5#”为系统命令,“1234”为编号)查看推广排名"}"
      else
        content = "温馨提示： 该商户没有目前没有需要推广的文章"
      end
    else
      content = "如果您想查看排名请先输入(如：“#绑定#”， “#绑定#”为系统命令,“”为您的姓名)来查看排名"
    end
    response_with_text_msg(@from_user_name, @to_user_name, content)
  end

end


class GeneralizePositionSystemMaterial < SystemMaterial
  # 推广营销排名: 5 1

  def set_passage(passage)
    @article = passage
  end

  def build_message
    if @article.get_user_promotion_count(@user) < @shop.least_promotion_number
      content = "温馨提示： 您的有效分享点击次数为#{@article.get_user_promotion_count(@user)},必须超过#{@shop.least_promotion_number}次有效点击才能看见您的排名。请继续努力让您的朋友点击哟！"
    else
      content = "推广排名\n\n"
      groups = @article.promotion_logs.all.group_by{|p| p.sharer}.sort_by{|k, v| v.length}.reverse
      Hash[groups.first(10)].select{|k,v| v.length >= @shop.least_promotion_number}.each_with_index do |(key, value), index|
        name = @shop.users.find_by(fake_user_name: key).name rescue nil
        content += "%-4s%10s%10s" % ["第#{index + 1}名", "#{value.size}次", "#{name || '未知'}\n"]
      end
      if @user.name
        index = Hash[groups].keys.index(@to_user_name)
        content += "\n你的推广排名为： 第#{index + 1}名" if index && index >= @shop.least_promotion_number
      end
    end
    response_with_text_msg(@from_user_name, @to_user_name, content.to_s)
  end
end

class QRCodeSystemMaterial < SystemMaterial
  # 二维码: 6

  def build_message
    system_config = @shop.system_configs.find_by(my_fake_id: @from_user_name)
    if system_config
      articles = []
      ticket = @user.ticket || Message.get_ticket(system_config, @user, @shop)
      if ticket
        content = "点击获得推广二维码 >>>>"
        articles << Article.new(title: "推广二维码链接", description: content, pic_url: @shop.image.medium.url, url: user_qrCode_path(@user.shop, @user))
        @user.update_attributes(ticket: ticket)
        response_with_news_msg(@from_user_name, @to_user_name, *articles)
      end
    end
  end
end

class CustomerServiceSystemMaterial < SystemMaterial
  def build_message
    system_config = @shop.system_configs.find_by(my_fake_id: @from_user_name)
    if system_config.present? && !system_config.gonghao_type && system_config.be_verified
      response_with_customer_service(@from_user_name, @to_user_name)
    end
  end
end