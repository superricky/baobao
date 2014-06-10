module Backend::ApplicationHelper
  def link_to_back
    link_to "返回", "javascript:window.history.back();", class: "btn btn-default"
  end

  def audio_tags(src)
    "<audio autoplay='autoplay'><source src='#{src}' type='audio/mpeg'/><embed hidden='true' autostart='true' loop='false' src='#{src}'/></audio>".html_safe
  end

  def system_config(table = {})
    menus = {
      shop_info: {icon: "home", url: "基本信息"},
      sms_message: {icon: "message", url: "短信设置"},
      credit: {icon: "compass", url: "积分设置"},
      wallet: {icon: "card", url: "余额设置"},
      pc_order: {icon: "cart", url: "PC下单设置"},
    }
    if @current_branch.present?
      menus = {
        branch_info: {icon: "home", url: "基本信息"},
        detail_info: {icon: "doc", url: "详细信息"},
        awards: {icon: "cooperation", url: "公司荣誉"},
        delivery_setting: {icon: "dining", url: "外卖设置"},
        order_setting: {icon: "menu", url: "接单设置"},
        scrachpad_setting: {icon: "scratch", url: "刮刮奖设置"}
      }
    end
    menus.each do |target, values|
      url = values[:url]
      icon = values[:icon]
      table[url] ||= {}
      table[url][:icon] = icon
      #if target.to_s == "shop_info"
      #  table[url][:url] = [backend_shop_path(@current_shop), target].join "#"
      #else
      table[url][:url] = "/backend/shops/#{@current_shop.slug}/shop_steps/#{target}?edit=true"
      table[url][:url] = "/backend/shops/#{@current_shop.slug}/branches/#{@current_branch.id}/branch_steps/#{target}?edit=true" if @current_branch.present?
      #end
    end
    menus = {
      帐号设置: {icon: "vip", url: backend_shop_accounts_path(@current_shop.slug)},
      邮件通知: {icon: "doc", url: backend_shop_mail_settings_path(@current_shop.slug)},
      计量单位: {icon: "dashboard", url: backend_shop_product_units_path(@current_shop.slug)},
      统计报表: {icon: "trend", url: backend_shop_statistics_month_path(@current_shop.slug)}
    }
    if @current_branch.present?
      menus = {
        帐号设置: {icon: "vip", url: backend_shop_branch_accounts_path(@current_shop.slug, @current_branch)},
        #自定义界面管理: {icon: "", url: backend_shop_branch_custom_ui_setting_path(@current_shop.slug, @current_branch)},
        自定义下单: {icon: "word", url: backend_shop_branch_form_elements_path(@current_shop.slug, @current_branch)},
        计量单位: {icon: "dashboard", url: backend_shop_branch_product_units_path(@current_shop.slug, @current_branch)},
        打印机管理: {icon: "order", url: backend_shop_branch_printers_path(@current_shop.slug, @current_branch)},
        商户短信: {icon: "message", url: backend_shop_branch_sms_msgs_path(@current_shop.slug, @current_branch)},
        统计报表: {icon: "trend", url: backend_shop_branch_statistics_month_path(@current_shop.slug, @current_branch)}
      }
      menus = menus.select{|k, v| ["自定义下单", "计量单位", "打印机管理", "商户短信", "统计报表"].include? k.to_s} if @current_account.is_worker?
    end
    menus.each do |title, values|
      url = values[:url]
      icon = values[:icon]
      table[title] ||= {}
      table[title][:icon] = icon
      table[title][:url] = url
    end
    table
  end

  def weixin_config(table = {})
    {
      公众账号: {icon: "groupon", url: backend_shop_system_configs_path(@current_shop.slug)},
      帐号菜单: {icon: "menu", url: backend_shop_system_configs_path(@current_shop.slug)},
      自动回复: {icon: "message", url: backend_shop_events_path(@current_shop.slug)},
      素材配置: {icon: "module", url: backend_shop_materials_path(@current_shop.slug)}
    }.each do |title, values|
      url = values[:url]
      icon = values[:icon]
      table[title] ||= {}
      table[title][:icon] = icon
      table[title][:url] = url
    end
    table
  end

  def payment(table = {})
    menus = {
      财付通: {icon: "cai", url: backend_shop_tenpay_path(@current_shop)},
      支付宝: {icon: "zhi", url: backend_shop_mobile_alipay_path(@current_shop)},
      交易流水: {icon: "cash", url: backend_shop_trades_path(@current_shop)}
    }
    if @current_branch.present?
      menus = {
        订单处理: {icon: "cash", url: backend_shop_branch_orders_path(@current_shop.slug, @current_branch, state: Order::WAIT_CONFIRMED)},
        订单流水: {icon: "cash", url: backend_shop_branch_trades_path(@current_shop.slug, @current_branch)}
      }
    end
    menus
  end

  def vip_manager(table = {})
    menus = {
      待审核客户: {icon: "groupon", url: appling_vip_backend_shop_users_path(@current_shop.slug)},
      微信用户: {icon: "vip", url: backend_shop_users_path(@current_shop.slug, type: "User")},
      网页用户: {icon: "vip", url: backend_shop_users_path(@current_shop.slug, type: "Member")},
      会员等级: {icon: "kind", url: backend_shop_vip_levels_path(@current_shop.slug)},
      积分详情: {icon: "order", url: backend_shop_credits_logs_path(@current_shop.slug)},
      余额管理: {icon: "cash", url: backend_shop_wallet_logs_path(@current_shop.slug)},
      用户留言: {icon: "message", url: leave_messages_backend_shop_messages_path(@current_shop.slug)},
      客户评价: {icon: "message", url: backend_shop_branch_comments_path(@current_shop.slug)}
    }
    if @current_branch.present?
      menus = {
        微信用户: {icon: "vip", url: backend_shop_branch_users_path(@current_shop.slug, @current_branch ,type: "User")},
        电话用户: {icon: "phone", url: backend_shop_branch_users_path(@current_shop.slug, @current_branch , type: "PhoneUser")},
        pc端用户: {icon: "message", url: backend_shop_branch_users_path(@current_shop.slug, @current_branch , type: "Member")},
        积分记录: {icon: "doc", url: backend_shop_branch_credits_logs_path(@current_shop.slug, @current_branch)}
        #客户购物车: {icon: "cart", url: backend_shop_branch_carts_path(@current_shop.slug, @current_branch)}
      }
    end
    menus
  end

  def branches_manager
    menus = {
      商户列表: {icon: "menu", url: backend_shop_branches_path(@current_shop.slug)},
      服务区域: {icon: "kind", url: backend_shop_zones_path(@current_shop.slug)},
      商户类型: {icon: "kind", url: backend_shop_branch_types_path(@current_shop.slug)},
      商户短信: {icon: "message", url: backend_shop_sms_msgs_path(@current_shop.slug)}
    }
    return menus.select{|k, v| ["商户列表", "商户短信"].include? k.to_s} if @current_account.is_worker?
    menus
  end

  def marketing
    menus = {
      企业动态: {icon: "doc", url: backend_shop_reports_path(@current_shop.slug)},
      商户推荐: {icon: "pic", url: backend_shop_branch_sliders_path(@current_shop.slug)},
      服务订单: {icon: "order", url: backend_shop_service_sale_orders_path(@current_shop.slug)},
      服务套餐: {icon: "order", url: backend_shop_service_products_path(@current_shop.slug)}
    }
    if @current_branch.present?
      menus = {
        促销活动: {icon: "gift", url: index_special_off_backend_shop_branch_promotions_path(@current_shop.slug, @current_branch)},
        产品幻灯片: {icon: "slideshow", url: backend_shop_branch_product_sliders_path(@current_shop.slug, @current_branch)},
        中奖结果: {icon: "cash", url: branch_index_backend_shop_branch_scrachpads_path(@current_shop.slug, @current_branch)}
      }
    end
    menus
  end

  def products
    menus = {}
    if @current_branch.present?
      menus = {
        产品管理: {icon: "gift", url: backend_shop_branch_products_path(@current_shop.slug, @current_branch)},
        产品分类: {icon: "kind", url: backend_shop_branch_categories_path(@current_shop.slug, @current_branch)},
        标签: {icon: "card", url: backend_shop_branch_tags_path(@current_shop.slug, @current_branch)}
      }
    end
  end

  def shop_menus
    menus = {
      system_config: {
        icon: "config",
        title: "基本",
        menus: system_config,
        oths: %w{accounts_show_my_account accounts_config_my_account}
      }
    }
    menus.merge!({products: {icon: "", title: "产品", menus: products}}) if @current_branch.present?
    menus.merge!({weixin_config: {
        icon: "phone",
        title: "微信",
        menus: weixin_config,
        oths: %w{menus_index menus_new}
      },
      payment: {
        icon: "cart",
        title: "订单",
        menus: payment,
        oths: %w{orders_index mobile_alipays_edit tenpays_edit}
      },
      vip_manager: {
        icon: "vip",
        title: "会员",
        menus: vip_manager
      },
      branches_manager: {
        icon: "cooperation",
        title: "商铺",
        menus: branches_manager,
        oths: %w{products_index products_index products_show branch_steps_show products_new}
      },
      marketing: {
        icon: "people",
        title: "营销",
        menus: marketing
      }
    })
    if @current_account.is_worker? && !@current_branch
      menus = {branches_manager: {
          icon: "cooperation",
          title: "商铺",
          menus: branches_manager,
          oths: %w{products_index products_index products_show branch_steps_show products_new}
        }
      }
    end
    menus
  end

  def current_menu
    {system_config: ["/backend/shops/xiaomi/dashboard", "shop_steps"]}.each do |main, urls|
      urls.each do |url|
        return main if request.path.include? url
      end
    end
    shop_menus.each do |main, table|
      if table[:oths].present? && table[:oths].index("#{controller_name}_#{action_name}")
        return main
      end
      table[:menus].each do |title, values|
        return main if values[:url].match /\/#{controller_name}/
        return main if values[:url].split("#").first == request.path
      end
    end
  end
end