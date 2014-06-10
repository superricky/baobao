class Ability
  include CanCan::Ability

  def initialize(account, controller_namespace)
    case controller_namespace
    when 'Backend'
      backend_namespace(account)
    else
    end
  end

  def backend_namespace(account)
    account ||= Account.new
    alias_action :update, :edit, to: :modify
    if account.is_admin?
      can :manage, :all
    elsif account.is_boss?
      can [:show, :edit, :update, :show_my_shop, :validation_domain, :config_my_shop, :update_my_shop, :dashboard, :change_branch_index], Shop do |shop|
        account.shop == shop
      end

      can :create, Account
      can [:index, :show], ServiceProduct
      can :manage, Account do |a|
        a.shop == account.shop
      end
      can [:show, :update, :change_state, :search, :index, :export_order, :change_state, :batch_change_state], Order do |order|
        account.shop == order.branch.shop
      end
      can :create, boss_manage_list
      can :manage, boss_manage_list do |model|
        account.shop == model.shop
      end
      can :create, Article
      can :manage, Article
    elsif account.is_worker?
      can [:show, :edit, :update, :index], Branch do |branch|
        account.shop == branch.shop && account.branches.include?(branch)
      end
      can [:show, :update, :change_state, :search, :index, :export_order, :batch_change_state, :change_state], Order do |order|
        account.shop == order.branch.shop && account.branch_ids.include?(order.branch_id)
      end
      can :create, worker_manage_list
      can :manage, worker_manage_list do |model|
        account.branch_ids.include?(model.branch_id)
      end
    end
    can [:index, :show], PostThreadLabel
    can [:create, :show, :index], PostThread
    can [:update, :destroy, :request_for_feature, :close_post], PostThread do |p|
      p.account == account
    end
    can :create, Post
  end

  def worker_manage_list
    [CustomUiSetting, ProductUnit, Printer, SmsMsg, Category, Tag, User,
      CreditsLog, Cart, Promotion, Scrachpad, ProductSlider, Statistic,
       Product, BrandChain, FormElement, Trade]
  end

  def boss_manage_list
    [ServiceSaleOrder, Branch, Theme, MailSetting, ProductUnit, SystemConfig, Event, CurrencySymbol,
      Material, User, VipLevel, CreditsLog, WalletLog, Zone, BranchType,Tenpay,MobileAlipay,
      Message, MessageThread, BranchComment, Report, BranchSlider, WeixinpayFeedback, WeixinpayWarning,
      BaseBranch, Statistic, Menu, PromotionLog].concat(worker_manage_list).uniq!
  end

end
