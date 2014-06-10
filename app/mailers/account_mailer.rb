require "setting"
class AccountMailer < ActionMailer::Base

  add_template_helper(OrdersHelper)
  def welcome_email(account, backend_login_url)
    set_smtp_setting_options(nil)
    @account = account
    @url  = backend_login_url
    mail(to: @account.email, subject: '恭喜您成功开通微信点单应用平台帐号')
  end

  def notify_new_order(order)
    @order = order
    @branch = @order.branch
    @shop = @branch.shop
    @mail_setting = @shop.get_mail_setting
    if @mail_setting.enable_mail
      to_list = []
      if @mail_setting.notify_shop_manager
        to_list += @shop.accounts.select{|account| account.is_boss? and account.email.present? and account.valid?}.map{|account| account.email}
      end

      if @branch.notify_new_order
        to_list += @branch.accounts.select{|account| account.email.present? and account.valid? }.map{|account| account.email}
      end
      unless to_list.uniq.empty?
        to_list.uniq.each do |to|
          begin
            AccountMailer.notify_one(to, @order, @branch, @shop).deliver
          rescue Exception => e
            logger.error e.message
          end
        end
        return
      end
    end
  end

  def notify_cancel_order(order)
    @order = order
    @branch = order.branch
    @shop = order.shop
    @mail_setting = @shop.get_mail_setting
    if @mail_setting.enable_mail
      to_list = []
      if @mail_setting.notify_shop_manager
        to_list += @shop.accounts.select{|account| account.is_boss? and account.email.present? and account.valid?}.map{|account| account.email}
      end
      if @branch.notify_new_order
        to_list += @branch.accounts.select{|account| account.email.present? and account.valid?}.map{|account| account.email}
      end
      unless to_list.uniq.empty?
        to_list.uniq.each do |to|
          begin
            AccountMailer.notify_order_cancel_one(to, @order, @branch, @shop).deliver
          rescue Exception => e
            logger.error e.message
          end
        end
      end
    end
  end

  def notify_remind_order(order)
    @order = order
    @branch = order.branch
    @shop = order.shop
    @mail_setting = @shop.get_mail_setting
    if @mail_setting.enable_mail
      to_list = []
      if @mail_setting.notify_shop_manager
        to_list += @shop.accounts.select{|account| account.is_boss? and account.email.present? and account.valid?}.map{|account| account.email}
      end
      if @branch.notify_new_order
        to_list += @branch.accounts.select{|account| account.email.present? and account.valid?}.map{|account| account.email}
      end
      unless to_list.uniq.empty?
        to_list.uniq.each do |to|
          begin
            AccountMailer.notify_order_remind_one(to, @order, @branch, @shop).deliver
          rescue Exception => e
            logger.error e.message
          end
        end
      end
    end
  end

  def notify_order_remind_one(to, order, branch, shop)
    set_smtp_setting_options(shop)
    @order = order
    @branch = branch
    @shop = shop
    mail(to: to, subject: "您的客户在催促订单#{@order.id}")
  end

  def notify_order_cancel_one(to, order, branch, shop)
    set_smtp_setting_options(shop)
    @order = order
    @branch = branch
    @shop = shop
    mail(to: to, subject: "您的客户已取消订单#{@order.id}")
  end

  def notify_scrachpad(order)
    order = order
    branch = order.branch
    shop = branch.shop
    to_list = []
    mail_setting = shop.get_mail_setting
    if mail_setting.enable_mail
      if mail_setting.notify_shop_manager
        to_list << shop.accounts.select{|account| account.is_boss? and account.email.present? and account.valid?}.map{|account| account.email}
      end
      to_list += branch.accounts.select{|account| account.email.present? and account.valid? }.map{|account| account.email}
      to_list.uniq.each do |to|
        AccountMailer.notify_scrachpad_result(to, order, branch, shop).deliver
      end
    end
  end

  def notify_one(to, order, branch, shop)
    set_smtp_setting_options(shop)
    @order = order
    @branch = branch
    @shop = shop
    mail(to: to, subject: "您的商户#{@branch.name}又有新的订单来了，请赶紧发货哦")
  end

  def notify_scrachpad_result(to, order, branch, shop)
    set_smtp_setting_options(shop)
    @order = order
    @branch = branch
    @shop = shop
    mail(to: to, subject: "你的商户#{branch.name}有人中奖了，赶快过来看一下！")
  end


  def test_config_mailer(shop)
    set_smtp_setting_options(shop)
    mail(to: shop.get_mail_setting.user_name,
         body: "您的邮箱配置成功，可以正常使用了！",
        content_type: "text/html",
         subject: "测试邮件")
  end

  private
  def set_smtp_setting_options(shop)
    mail_setting = shop.get_mail_setting rescue nil
    unless mail_setting.nil? || mail_setting.use_system_setting
      ActionMailer::Base.default :from => "#{shop.name} <#{mail_setting.user_name}>", :reply_to => mail_setting.reply_to
      ActionMailer::Base.delivery_method = mail_setting.delivery_method.to_sym
      ActionMailer::Base.smtp_settings[:address] = mail_setting.address
      ActionMailer::Base.smtp_settings[:user_name] = mail_setting.user_name
      ActionMailer::Base.smtp_settings[:password] = mail_setting.password
      ActionMailer::Base.smtp_settings[:port] = mail_setting.port
      ActionMailer::Base.smtp_settings[:authentication] = mail_setting.authentication.to_sym
      ActionMailer::Base.smtp_settings[:enable_starttls_auto] = mail_setting.enable_starttls_auto
      ActionMailer::Base.smtp_settings[:domain] = mail_setting.domain
    else
      ActionMailer::Base.default :from => Settings.email.default_from, :reply_to => Settings.email.reply_to
      ActionMailer::Base.delivery_method = Settings.email.delivery_method.to_sym
      ActionMailer::Base.smtp_settings[:address] = Settings.email.address
      ActionMailer::Base.smtp_settings[:user_name] = Settings.email.user_name
      ActionMailer::Base.smtp_settings[:password] = Settings.email.password
      ActionMailer::Base.smtp_settings[:port] = Settings.email.port
      ActionMailer::Base.smtp_settings[:authentication] = Settings.email.authentication.to_sym
      ActionMailer::Base.smtp_settings[:enable_starttls_auto] = Settings.email.enable_starttls_auto
      ActionMailer::Base.smtp_settings[:domain] = Settings.email.domain
    end
  end
end
