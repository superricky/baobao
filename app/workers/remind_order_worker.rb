#encoding:utf-8
class RemindOrderWorker
  include Sidekiq::Worker
  include OrdersHelper

  def perform(order_id)
    order = Order.find(order_id) rescue nil
    if order
      begin
        logger.info "start to send remind order by email"
        AccountMailer.notify_remind_order(order)
      rescue => e
        logger.error e.message
      end

      begin
        send_remind_order_msg(order)
      rescue =>e
        logger.error e.message
      end

      begin
        ManagePrinter.new(order).print_orders_to_feyin_printer(ManagePrinter::REMIND_ORDER)
      rescue => e
        logger.error e.message
      end
    end
  end
end