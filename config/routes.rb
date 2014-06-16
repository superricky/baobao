Rails.application.routes.draw do

  captcha_route
  #TODO: add by xie subin, will be deleted in future
  scope "/weixinpay" do
    post "priority_notify" => "weixinpays#priority_notify", :shop_slug=>"tuodanbao"
    post "warning" => "weixinpays#warning", :shop_slug=>"tuodanbao"
    scope :module => "client" do
      get "client" => "shops#show", :shop_slug=>"tuodanbao", as: :tuodanbao_client_root
    end
  end
  devise_for :members, controllers: {confirmations: "webstore/members/confirmations", sessions: "webstore/members/sessions", registrations: "webstore/members/registrations"}
  constraints Subdomain do
    match "/" => "webstore/shops#show", via: [:get], as: :webstore_welcome
    namespace :webstore do
      get ":shop_id" => "shops#show", as: :shop
      scope ':shop_id' do
        resources :branches do
          resources :products
        end
        resources :orders
        get "branches/:branch_id/order/send_phone_validation_code/:phone" => "orders#send_phone_validation_code"
        post "branches/:branch_id/order/validation_code" => "orders#validation_code"
        post "branches/:branch_id/orders" => "orders#create"
      end

      get "cart/index"
      get "cart/order"

      get ":shop_id/member/show" => "member#show", as: :member_show
      get ":shop_id/member/edit" => "member#edit", as: :member_edit
      match ":shop_id/member/update" => "member#update", via:[:put, :patch], as: :member

      devise_scope :member do
        post ":shop_id/members/sign_in" => "members/sessions#create", as: :sign_in
        delete ":shop_id/members/signout" => "members/sessions#destroy", as: :signout
        get ":shop_id/members/sign_up" => "members/registrations#new", as: :sign_up
        post ":shop_id/members" => "members/registrations#create", as: :registrations
        get ":shop_id/members/edit" => "members/registrations#edit", as: :registrations_edit
        put ":shop_id/members" => "members/registrations#update", as: :registration
        get ":shop_id/members/confirmation" => "members/confirmations#show", as: :member_confirmation
      end
    end
  end

  require 'sidekiq/web'
  scope '/api' do
    #支付宝验证到帐相关接口
    post 'alipay_notify/:service_sale_order_id' => "alipays#alipay_notify", as: :alipay_notify
  end

  #mount Api::Backend => '/api_backend'
  devise_scope :account do
    root :to => 'backend/sessions#new'
  end
  concern :accounts_concern do
    resources :accounts do
      member do
        get 'edit_password'
        get 'reset_password'
        match 'update_password', via: [:put, :patch]
        get 'account_branch'
      end
      collection do
        get 'show_my_account'
        get 'config_my_account'
        match 'update_my_account', via: [:put, :patch]
        get 'edit_my_password'
        match 'update_my_password', via: [:put, :patch]
      end
    end
  end

  scope "/shop/:shop_slug" do
    root :to => 'client/shops#show', as: :shop_root
    resource :weixinpay do
      root :to => 'client/shops#show'
      get "client" => "client/shops#show"
      get "weixin_pay_params"
      post "notify_weixin_pay_result"
      post "priority_notify"
      post "warning"
    end

    resource :tenpay do
      post 'notify'
    end

    resource :mobile_alipay do
      post 'notify'
    end

    namespace :client do
      resources :orders do
        collection do
          get 'send_validation_code'
          get 'validation_code'
          get 'query'
        end
        member do
          get 'mobile_alipay'
          match 'cancel', to: :cancel, via: [:put, :patch, :get]
          match 'reminder', to: :reminder, via: [:get]
        end
      end
    end

    get "line_items/index"
    resources :user, only: :none do
      get '/oauth' => 'messages#oauth', as: :oauth
      get '/qrCode' => 'messages#qrCode', as: :qrCode
      get '/get_audiences_info' => 'messages#get_audiences_info', as: :get_audiences_info
    end
    get '/api' => 'messages#validate', as: :message_validate_root
    post '/api' => 'messages#create', as: :message_create_root
  end

  namespace :mobile do
    resources :shops, only: :none do
      resources :branches, only: :none do
        collection do
          get 'list'
        end
        member do
          get 'about_my_shop'
        end
        resources :scrachpads, only: [:show, :destroy, :index] do
          get 'open', on: :member
        end
        resources :products, only: :none do
          collection do
            get 'list'
            get 'categories'
            post 'search'
            get 'search'
          end

          member do
            get 'show'
          end
        end
        resources :line_items, only: [:create, :destroy]
        resources :sms_msgs do
          collection do
            match 'search' => 'sms_msgs#search', via: [:get, :post], as: :search
          end
        end
        resources :orders, only: [:create, :new] do
          member do
            get 'detail'
            patch 'cancel'
            post 'cancel'
          end
          collection do
            get 'send_validation_code'
            get 'query'
            get 'choose_order_type'
          end
        end

        get '/clear_my_cart', to: 'carts#clear_my_cart', as: :clear_my_cart
        get '/my_cart', to: 'carts#my_cart', as: :my_cart

        get '/myprofile', to: 'users#myprofile', as: :myprofile
        get '/account', to: 'users#account', as: :account
        match 'update_myprofile', to: 'users#update_myprofile', as: :update_myprofile, via: [:post, :patch]

        get '/detail_special_off', to: 'promotions#detail_special_off', as: :detail_special_off
      end
      resources :materials, only: :none do
        get 'articles/:id', to: "articles#show", as: :show_article
      end
    end
  end


  concern :credits_logs_concern do
    resources :credits_logs do
      collection do
        match 'search' => 'credits_logs#search', via: [:get, :post]
      end
    end
  end

  namespace :backend do
    root to: 'site_configs#index', :via => [:get], :as => :system_admin_root
    resources :service_sale_orders, only: [:index, :show]
    resources :transaction_logs
    resources :service_products do
      match 'change_position',  via: [:patch, :put],on: :collection
    end
    resources :agents
    resources :agent_zones
    resources :product_units
    resources :post_thread_labels
    resources :post_threads do
      member do
        post 'request_for_feature'
        put 'toggle_publish'
        put 'close_post'
      end
      resources :posts
    end
    resources :site_configs
    concerns :accounts_concern
    post 'export_accounts' => "accounts#export_accounts", as: :export_accounts
    resources :shops, concerns: [:accounts_concern, :credits_logs_concern] do
      match 'change_branch_index', via: [:put, :patch], on: :member
      # member do
      #   get "wechat_pays/:id/show", as: :show_wechat_pay
      #   get "wechat_pays/:id/edit", as: :edit_wechat_pay
      #   match "wechat_pays/:id/update", via: [:put, :patch], as: :update_wechat_pay
      #   get "wechat_pays/index", as: :wechat_pays
      # end
      resources :wechat_pays
      resources :weixinpay_warnings
      resources :weixinpay_feedbacks
      resources :trades
      resource :tenpay
      resource :mobile_alipay
      resources :currency_symbols

      resources :phone_orders, only: :none do
        collection do
          get :branch_list
        end
        member do
          get :category_list
          post :order_create
          post :phone_user_info
        end
      end

      resources :service_sale_orders do
        get 'pay_with_alipay', on: :member
      end
      resources :service_products,only: :index
      member do
        get 'validation_domain'
        get 'dashboard'
        get 'show_my_shop'
        get 'config_my_shop'
        match '/update_my_shop', to: 'shops#update_my_shop', as: :update_my_shop, via:[:post, :patch]
      end
      resources :shop_steps
      resources :sms_msgs do
        collection do
          match 'search' => 'sms_msgs#search', via: [:get, :post], as: :search
        end
      end
      resources :brand_chains

      resources :base_branches do
        collection do
          put 'change_position'
        end
      end
      resources :product_units

      resources :mail_settings, only: :none do
        get 'edit', on: :collection
        get 'show', on: :collection
        match 'update', to: :update, via: [:put, :patch]
        collection do
          get 'test_config_email'
        end
      end
      get "statistics/shop_stat_month", as: :statistics_month
      get "statistics/shop_stat_year", as: :statistics_year
      resources :scrachpads, only: :none  do
        get 'shop_index', on: :collection
      end
      resources :vip_levels
      resources :branch_comments do
          post 'toggle_pub', on: :member
      end
      resources :wallet_logs do
        collection do
          match 'search' => 'wallet_logs#search', via: [:get, :post], as: :search
        end
        member do
          delete 'rollback_recharge', as: :rollback_recharge
        end
      end
      resources :reports
      resources :zones
      resources :branch_sliders do
        member do
          post 'change_position'
        end
      end
      resources :branch_types
      resource :theme
      resources :credits_logs do
        collection do
          match 'search' => 'credits_logs#search', via: [:get, :post]
        end
      end
      resources :message_threads do
        collection do
          match 'search' => 'message_threads#search', via: [:get, :post]
        end
        resources :messages, only: [:index]
      end
      resources :messages, only: :none do
        get 'leave_messages', on: :collection
        collection do
          match 'search' => 'messages#search', via: [:get, :post], as: :search
        end
      end
      resources :users do
        get 'approve_vip_user', on: :member
        put 'create_vip_user', on: :member
        get 'reset_validation_code_times', on: :member
        put 'block', on: :member
        get 'vip_edit', on: :member
        get 'appling_vip', on: :collection
        match 'recharge', on: :member, via: [:put, :patch]
        collection do
          match 'search' => 'users#search', via: [:get, :post], as: :search
        end
        member do
          match 'search_log' => 'users#search_log', via: [:get, :post], as: :search_log
        end
      end
      resources :system_configs do
        collection do
          get 'change'
          get 'auto_config_new'
          post 'auto_config_create'
        end
        put 'copy_menu_to_other', on: :member
        resources :menus do
          collection do
            get 'async'
            get 'preview_json'
          end
        end
      end
      resources :events do
        collection do
          get 'unmatch_message'
        end
      end
      resources :materials do
        resources :articles do
          get 'preview', on: :collection
        end
        get 'articles/:id', to: "articles#show", as: :show_article
      end

      resources :branches, concerns: [:credits_logs_concern] do
        collection do
          put :exchange_position
        end
        member do
          post :assign_account
          delete :remove_account
        end
        resources :product_sliders do
          member do
            post :change_position
          end
        end
        resources :trades
        resources :branch_steps
        resources :credits_logs, only: [:index, :show, :new, :create, :edit, :update] do
          collection do
            match 'search' => 'credits_logs#search', via: [:get, :post], as: :search
          end
          member do
            delete 'rollback_credits', as: :rollback_credits
          end
        end
        resources :scrachpads, only: :none  do
          get 'branch_index', on: :collection
          post 'deactivate', on: :member
          collection do
            match 'search' => 'scrachpads#search', via: [:get, :post], as: :search
          end
        end
        resources :users do
          put 'block', on: :member
          collection do
            match 'search' => 'users#search', via: [:get, :post], as: :search
          end
          member do
            match 'search_log' => 'users#search_log', via: [:get, :post], as: :search_log
          end
        end
        resources :sms_msgs do
          collection do
            match 'search' => 'sms_msgs#search', via: [:get, :post], as: :search
          end
        end
        resources :product_units
        resources :tags
        resources :categories do
          member do
            post :add_product
            post 'change_position'
          end
          delete "/remove_product/:product_id", to: "categories#remove_product", as: "remove_product"
        end
        resources :carts, except: [:my_cart, :clear_my_cart] do
          resources :line_items
        end
        resources :products do
          collection do
            post :import_product, to: "products#import_product" , as: :import_product
            match 'search' => 'products#search', via: [:get, :post], as: :search
          end
          member do
            post :change_position
          end
          get :category, on: :collection
          post :copy_to_branch, on: :collection
          delete :batch_remove, on: :collection
          post :batch_added, on: :collection
          post :batch_shelve, on: :collection
        end
        resource :custom_ui_setting

        get "statistics/branch_stat_month", as: :statistics_month
        get "statistics/branch_stat_year", as: :statistics_year

        resources :orders do
          member do
            post 'change_state'
          end
          collection do
            post 'export_order'
            post 'batch_change_state'
            get 'search'
          end
        end
        resources :printers

        resources :promotions do
          collection do
            get 'index_special_off'
            get 'new_special_off'
            post 'create_special_off'
          end
          member do
            get 'show_special_off'
            get 'edit_special_off'
            delete 'destroy_special_off'
            match 'update_special_off', :via=>[:post, :patch]
          end
        end
        resources :form_elements do
          collection do
            get 'new_select'
            get 'new_textarea'
            post 'save_sequence'
          end
        end
        concerns :accounts_concern
      end
      resources :promotion_logs do
        collection do
          get 'article_promotion'
          get 'promotion_user'
        end
      end
      resources :qrcode_generalizes do
        collection do
          get 'promotion_user'
          get 'user_generalizes'
        end
      end
    end
    mount Ckeditor::Engine => '/ckeditor'
    mount Sidekiq::Web, at: '/sidekiq'
    devise_scope :account do
      get "login" => "sessions#new", as: :login
      get "sign_up" => "registrations#new", as: :sign_up
      delete "/signout" => "sessions#destroy"
      root to: "sessions#new", as: :account_root
    end
  end

  devise_for :accounts, controllers: {sessions: "backend/sessions", registrations: "backend/registrations", unlocks: "backend/unlocks", confirmations: "backend/confirmations", passwords: "backend/passwords"}
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
