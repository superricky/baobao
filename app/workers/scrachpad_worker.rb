#encoding:utf-8
class ScrachpadWorker
  include Sidekiq::Worker
  include OrdersHelper
  def perform(order_id)
    order = Order.find(order_id)
    begin
      AccountMailer.notify_scrachpad(order)
    rescue => e
      logger.error e.message
    end
    begin
      ManagePrinter.new(order).print_orders_to_feyin_printer(ManagePrinter::PRAISE_NOTICE)
    rescue => e
      logger.error e.message
    end

    begin
      send_scrachpad_msg(order)
    rescue =>e
      logger.error e.message
    end
  end
end