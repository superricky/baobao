#encoding:utf-8
class CancelOrderWorker
  include Sidekiq::Worker

  def perform(order_id)
    order = Order.find(order_id) rescue nil
    if order
      begin
        logger.info "start to send cancel order by email"
        AccountMailer.notify_cancel_order(order)
      rescue => e
        logger.error e.message
      end

      begin
        send_cancel_order_msg(order)
      rescue =>e
        logger.error e.message
      end

      begin
        ManagePrinter.new(order).print_orders_to_feyin_printer(ManagePrinter::CANCEL_ORDER)
      rescue => e
        logger.error e.message
      end
    end
  end
end