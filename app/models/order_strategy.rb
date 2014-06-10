#encoding: utf-8
class OrderStrategy


  def create_credits_log(order, credit_log_type, credits, account_id=nil, note="")
    order.credits_logs.create!({
      :user=> order.user,
      :shop=>order.shop,
      :branch=>order.branch,
      :credit_log_type => credit_log_type,
      :credits => credits,
      :account_id => account_id,
      :note => note,
      :shop_credits_given_after =>order.shop.credits_given,
      :shop_credits_consume_after => order.shop.credits_consume,
      :branch_credits_given_after => order.branch.credits_given,
      :branch_credits_consume_after => order.branch.credits_consume,
      :user_credits_balance_after => order.user.credits
      })
  end


  def create_wallet_log(order, wallet_log_type, account_id=nil, note="")
    order.wallet_logs.create!({
      :user=> order.user,
      :shop=>order.shop,
      :branch=>order.branch,
      :wallet_log_type => wallet_log_type,
      :money => order.consume_wallet,
      :account_id => account_id,
      :note => note,
      :shop_wallet_given_after =>order.shop.wallet_given,
      :shop_wallet_consume_after => order.shop.wallet_consume,
      :branch_wallet_given_after => order.branch.wallet_given,
      :branch_wallet_consume_after => order.branch.wallet_consume,
      :user_wallet_balance_after => order.user.wallet
      })
  end

  def cart_amount(cart)
    cart.line_items.inject(0.0) do |sum, line_item|
      sum += line_item.quantity * line_item.product.original_price
    end
  end

  def self.product_price_with_promotion_detail(product, user, promotion_detail)
    discount = 1.0

    if !user.is_a?(Member) && (user.present? && user.vip_level.present?)
      discount = user.vip_level.discount
    end

    if promotion_detail.present?
      [promotion_detail.price, product.original_price * discount, product.original_price].min
    else
      [product.original_price * discount, product.original_price].min
    end
  end

  def self.product_price(product, user)
    promotion = Promotion::get_current_promotion_for_branch(product.branch)
    if promotion.present?
        promotion_detail = promotion.promotion_details.find_by_product_id(product.id)
    end
    self.product_price_with_promotion_detail(product, user, promotion_detail)
  end

  def is_valid_credits_consume?(cart, delivery_fee, credits)
    (credits>=0) && (cart_amount_after_discount(cart) +delivery_fee) >= (credits.to_f/cart.shop.credit_for_each_money)
  end

  def is_valid_wallet_consume?(cart, delivery_fee, wallet)
    (wallet>=0) && (cart_amount_after_discount(cart)+delivery_fee) >= wallet
  end

  def is_valid_credits_wallet_consume(cart, delivery_fee, wallet, credits)
    is_valid_credits_consume?(cart, delivery_fee, credits) && is_valid_wallet_consume?(cart, delivery_fee, wallet) &&
    ( (cart_amount_after_discount(cart)+delivery_fee) >= ((credits.to_f/cart.shop.credit_for_each_money) + wallet))
  end

  #折扣计算
  ##会员折扣计算
  ##促销折扣计算
  ##优惠券计算
  ##外送费计算
  def cart_amount_after_discount(cart)
    cart.line_items.inject(0.0) do |amount, line_item|
      amount += line_item.quantity * line_item.product.price(cart.user)
    end
  end

  def pay_order_need_credits(cart)
    cart_amount_after_discount(cart) * cart.shop.credit_for_each_money
  end

  def pay_order_need_balance(cart)
    cart_amount_after_discount(cart)
  end

  ##余额支付和积分支付之后产生的现金部分
  def cash_amount_after_paytype(cart, delivery_fee, wallet_part = 0, credits_part = 0)
    if not is_valid_credits_wallet_consume(cart, delivery_fee, wallet_part, credits_part)
      raise Exception.new("Illegal input with money, wallet_part and credits_part")
    end
    original_amount = cart_amount_after_discount(cart)+delivery_fee
    original_amount -= (credits_part.to_f/cart.shop.credit_for_each_money)
    original_amount -= wallet_part
  end

  def money_exchange_from_credits(shop, credits_part)
    credits_part.to_f / shop.credit_for_each_money
  end


  def cart_quantity(cart)
    cart.line_items.inject(0) do |sum, line_item|
      sum += line_item.quantity
    end
  end

  def credits_total_return(cart, credits_part)
    if(credits_part > 0)
      #如果使用积分支付，整个订单将不再返还积分
      0
    else
      cart.line_items.inject(0.0) do |sum, line_item|
        sum += line_item.quantity * line_item.product.credits_for_each_product
      end
    end
  end

  def delivery_fee(cart, order_type, delivery_zone)
    if (order_type.nil? or order_type.empty? or (order_type == Order::ORDERTYPE_DELIVERY)) && cart.branch.use_min_order_charge && (cart_amount_after_discount(cart) < cart.branch.min_order_charge)
      delivery_zone.charge rescue 0
    else
      0
    end
  end

  #能够使用的优惠券
  def coupons_applicable(cart)
  end

  def scrachpads_return(cart)
  end

end