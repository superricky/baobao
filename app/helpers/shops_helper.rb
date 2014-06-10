#encoding:utf-8;
module ShopsHelper
  def backend_shop_navigations
    {
      我想添加商户: new_backend_shop_branch_path(@current_shop),
      我想开通账号: new_backend_shop_account_path(@current_shop),
      我要查看用户信息: backend_shop_users_path(@current_shop),
      我要管理旗下商户: backend_shop_branches_path(@current_shop),
      我要添加幻灯片: new_backend_shop_branch_slider_path(@current_shop),
      我要设置微信素材: backend_shop_materials_path(@current_shop),
      我要查看用户的积分消费记录: backend_shop_credits_logs_path(@current_shop),
      我要查看用户的余额消费记录: backend_shop_wallet_logs_path(@current_shop)
    }
  end
end
