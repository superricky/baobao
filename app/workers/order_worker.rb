#encoding:utf-8
class OrderWorker
  include Sidekiq::Worker
  include OrdersHelper

  def perform(order_id, url)
    order = Order.find(order_id) rescue nil
    if order
      begin
          logger.info "start to send order by email"
          AccountMailer.notify_new_order(order)
      rescue => e
        logger.error e.message
      end


      begin
        PhonegapPushManager.notify_order_to_android_app(order)
      rescue => e
        logger.error e.message
      end

      begin
        accounts_to_notify = order.shop.accounts.select{|account| account.is_boss? or account.branch_ids.include?(order.branch_id)}
        accounts_to_notify.each do |account|
          puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>start_in_private_pub.publish_to"
          PrivatePub.publish_to "/messages/accounts/#{account.id}", :msg => {
            :title => "您有新的订单来了",
            :content => "您的商户[#{order.branch.name}]又有新的订单了，请在\"#{order.state_name}订单\"列表中对该订单进行处理",
            :link => url
          }
        end
      rescue Exception => se
        logger.error "Got error: unable to pub new orders, my be private_pub server is down.( #{se})"
      end

      begin
        send_order_msg(order)
      rescue =>e
        logger.error e.message
      end

      begin
        order.send_order_to_wechat
      rescue =>e
        logger.error e.message
      end


      begin
        ManagePrinter.new(order).print_orders_to_feyin_printer(ManagePrinter::NEW_ORDER_NOTICE)
      rescue => e
        logger.error e.message
      end
    end
  end
end