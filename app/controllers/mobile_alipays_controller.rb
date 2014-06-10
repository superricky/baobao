#encoding: utf-8
include MobileAlipayUtils
class MobileAlipaysController < ApplicationController
  protect_from_forgery :except => [:notify]
  before_filter :validate_request, only: :notify
  def notify
    body_hash = Rack::Utils.parse_query(@body).to_options
    notify_data = Hash.from_xml(body_hash[:notify_data]).to_options[:notify].to_options
    @order = @current_shop.orders.find(notify_data[:out_trade_no])
    if @order.is_mobile_alipay_type? and
      @order.trade.nil? and
      ["TRADE_FINISHED", "TRADE_SUCCUSS"].include? notify_data[:trade_status]
      @order.create_trade(:trade_id=>notify_data[:trade_no],
          :trade_type=> Order::PAY_BY_MOBILE_ALIPAY_TYPE,
          :query=>@body,
          :body=>body_hash[:notify_data],
          :partner=> notify_data[:seller_id],
          :total_fee=>notify_data[:price].to_f * 100,
          :out_trade_no=>notify_data[:out_trade_no],
          :shop_id=>@order.shop_id,
          :branch_id=> @order.branch_id)
      render :text => 'success'
    elsif @order.is_mobile_alipay_type? and @order.is_paid?
      render :text => 'success'
    else
      render :text => 'fail'
    end
  end

  private
  def validate_request
    @mobile_alipay = @current_shop.mobile_alipay
    @body = request.body.read
    unless validate_notify_request(@mobile_alipay, @body)
      raise "invalid notify request #{@body}"
    end
  end
end