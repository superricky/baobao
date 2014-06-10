#encoding: utf-8
class PhonegapPushManager
  def self.notify_order_to_android_app(order)
    branch = order.branch
    branch_id = branch.id
    shop = branch.shop
    accounts = []
    shop.accounts.each do|account|
      if account.is_boss? or account.branches.include? branch
        accounts << account
      end
    end
    if accounts.present?
      push_regs = []
      accounts.each do|account|
        if account.push_regs.present?
          push_regs += account.push_regs
        end
      end
      if push_regs.present?
        GCM.send_notification( push_regs.map(&:registration_id), {:message => "恭喜,您的店铺#{order.branch.name}有新的订单（订单号：#{order.id} 金额: ¥#{order.amount.to_s}元），请打开获取新的订单", :event_type=>'new_order'})
      end
    end
  end

end