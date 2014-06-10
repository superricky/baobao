# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140526073208) do

  create_table "accounts", force: true do |t|
    t.string   "login_id",               limit: 191
    t.string   "name",                   limit: 191
    t.string   "email",                  limit: 191
    t.string   "encrypted_password",     limit: 191
    t.string   "last_sign_in_ip",        limit: 191
    t.string   "phone",                  limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
    t.string   "reset_password_token",   limit: 191
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 191
    t.string   "confirmation_token",     limit: 191
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",                    default: 0
    t.string   "unlock_token",           limit: 191
    t.datetime "locked_at"
    t.integer  "user_id"
  end

  add_index "accounts", ["confirmation_token"], name: "index_accounts_on_confirmation_token", unique: true, using: :btree
  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
  add_index "accounts", ["login_id"], name: "index_accounts_on_login_id", unique: true, using: :btree
  add_index "accounts", ["phone"], name: "index_accounts_on_phone", using: :btree
  add_index "accounts", ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree
  add_index "accounts", ["shop_id"], name: "index_accounts_on_shop_id", using: :btree
  add_index "accounts", ["user_id"], name: "index_accounts_on_user_id", using: :btree

  create_table "accounts_branches", id: false, force: true do |t|
    t.integer "account_id", null: false
    t.integer "branch_id",  null: false
  end

  create_table "accounts_roles", id: false, force: true do |t|
    t.integer "account_id"
    t.integer "role_id"
  end

  add_index "accounts_roles", ["account_id", "role_id"], name: "index_accounts_roles_on_account_id_and_role_id", using: :btree

  create_table "agent_rels", force: true do |t|
    t.integer  "agent_id"
    t.integer  "agent_zone_id"
    t.datetime "agent_from"
    t.datetime "agent_to"
  end

  create_table "agent_zones", force: true do |t|
    t.string   "name",                 limit: 191
    t.integer  "parent_agent_zone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agent_zones", ["parent_agent_zone_id"], name: "index_agent_zones_on_parent_agent_zone_id", using: :btree

  create_table "agents", force: true do |t|
    t.string   "aid",        limit: 191
    t.string   "name",       limit: 191
    t.string   "phone",      limit: 191
    t.decimal  "balance",                precision: 8, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "angel_types", force: true do |t|
    t.string   "name",                   limit: 191
    t.decimal  "discount",                           precision: 3, scale: 2, default: 1.0
    t.integer  "max_valid_times"
    t.integer  "shop_id"
    t.integer  "rebates_credits_return",                                     default: 0
    t.decimal  "rebates_wallet_return",              precision: 8, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "angel_types", ["shop_id"], name: "index_angel_types_on_shop_id", using: :btree

  create_table "angels", force: true do |t|
    t.string  "angel_number",    limit: 191
    t.integer "angel_type_id"
    t.integer "shop_id"
    t.integer "rebates_credits",                                     default: 0
    t.decimal "rebates_wallet",              precision: 8, scale: 2, default: 0.0
    t.integer "orders_count",                                        default: 0
  end

  add_index "angels", ["angel_type_id"], name: "index_angels_on_angel_type_id", using: :btree
  add_index "angels", ["shop_id"], name: "index_angels_on_shop_id", using: :btree

  create_table "api_keys", force: true do |t|
    t.string   "access_token", limit: 191,                null: false
    t.datetime "expires_at"
    t.integer  "owner_id",                                null: false
    t.string   "owner_type",   limit: 191,                null: false
    t.string   "ip_address",   limit: 191,                null: false
    t.string   "location",     limit: 191
    t.boolean  "active",                   default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "articles", force: true do |t|
    t.string   "title",             limit: 191
    t.text     "description"
    t.string   "pic_url",           limit: 191
    t.text     "url"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "owner_type",        limit: 191
    t.string   "image",             limit: 191
    t.string   "img_url",           limit: 191
    t.string   "link_type",         limit: 191
    t.datetime "expiration_time"
    t.integer  "position",                      default: 1
    t.boolean  "support_promotion"
    t.text     "introduction"
  end

  add_index "articles", ["owner_id"], name: "index_articles_on_owner_id", using: :btree

  create_table "awards", force: true do |t|
    t.string   "name",        limit: 191
    t.text     "description"
    t.integer  "branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "awards", ["branch_id"], name: "index_awards_on_branch_id", using: :btree

  create_table "base_users", force: true do |t|
    t.string   "phone",                               limit: 191
    t.string   "default_address",                     limit: 191
    t.string   "name",                                limit: 191
    t.string   "fake_user_name",                      limit: 191
    t.string   "email_address",                       limit: 191
    t.datetime "subscribe_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_login_ip",                       limit: 191
    t.integer  "shop_id"
    t.integer  "orders_count"
    t.integer  "credits",                                                                  default: 0
    t.string   "vip_no",                              limit: 191
    t.datetime "last_sent_validation_code_time"
    t.integer  "sent_validation_code_times_in_today",                                      default: 0
    t.decimal  "last_latitude",                                   precision: 10, scale: 6
    t.decimal  "last_longitude",                                  precision: 10, scale: 6
    t.string   "last_location_label",                 limit: 191
    t.datetime "last_location_time"
    t.boolean  "is_blocked",                                                               default: false
    t.integer  "vip_level_id"
    t.string   "pay_password_hash",                   limit: 191
    t.decimal  "wallet",                                          precision: 8,  scale: 2, default: 0.0
    t.decimal  "total_amount",                                    precision: 8,  scale: 2, default: 0.0
    t.integer  "angel_id"
    t.integer  "recommend_user_id"
    t.boolean  "is_apply_vip_user",                                                        default: false
    t.string   "my_fake_id",                          limit: 191
    t.string   "type",                                limit: 191
    t.string   "email",                               limit: 191,                          default: ""
    t.string   "encrypted_password",                  limit: 191,                          default: ""
    t.string   "reset_password_token",                limit: 191
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                                            default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",                  limit: 191
    t.string   "last_sign_in_ip",                     limit: 191
    t.integer  "order_webstores_count",                                                    default: 0
    t.string   "confirmation_token",                  limit: 191
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "host",                                limit: 191
    t.integer  "member_id"
    t.string   "ticket",                              limit: 191
    t.integer  "scene_id"
    t.integer  "generalize_user_id"
    t.integer  "audiences_count",                                                          default: 0
    t.string   "nickname",                            limit: 191
    t.text     "headimgurl"
  end

  add_index "base_users", ["angel_id"], name: "index_base_users_on_angel_id", using: :btree
  add_index "base_users", ["fake_user_name"], name: "index_base_users_on_fake_user_name", using: :btree
  add_index "base_users", ["generalize_user_id"], name: "index_base_users_on_generalize_user_id", using: :btree
  add_index "base_users", ["recommend_user_id"], name: "index_base_users_on_recommend_user_id", using: :btree
  add_index "base_users", ["shop_id"], name: "index_base_users_on_shop_id", using: :btree

  create_table "branch_comments", force: true do |t|
    t.string   "name",       limit: 191
    t.integer  "user_id"
    t.text     "content"
    t.integer  "level",                  default: 5
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.boolean  "can_pub",                default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "branch_comments", ["branch_id"], name: "index_branch_comments_on_branch_id", using: :btree
  add_index "branch_comments", ["shop_id"], name: "index_branch_comments_on_shop_id", using: :btree
  add_index "branch_comments", ["user_id"], name: "index_branch_comments_on_user_id", using: :btree

  create_table "branch_sliders", force: true do |t|
    t.string   "img",        limit: 191
    t.text     "desc"
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "position",               default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "branch_sliders", ["shop_id"], name: "index_branch_sliders_on_shop_id", using: :btree

  create_table "branch_types", force: true do |t|
    t.string   "name",           limit: 191
    t.integer  "branches_count",             default: 0
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "branch_types", ["shop_id"], name: "index_branch_types_on_shop_id", using: :btree

  create_table "branches", force: true do |t|
    t.integer  "shop_id"
    t.string   "name",                                    limit: 191
    t.boolean  "is_open",                                                                      default: true
    t.time     "service_period_start",                                                         default: '2000-01-01 00:00:00'
    t.time     "service_period_end",                                                           default: '2000-01-01 23:59:00'
    t.datetime "expiration_time"
    t.string   "notice",                                  limit: 191
    t.decimal  "income",                                              precision: 10, scale: 2, default: 0.0
    t.string   "telephone",                               limit: 191
    t.string   "address",                                 limit: 191
    t.string   "zip_code",                                limit: 191
    t.decimal  "latitude",                                            precision: 10, scale: 6
    t.decimal  "longitude",                                           precision: 10, scale: 6
    t.integer  "products_count",                                                               default: 0
    t.integer  "carts_count",                                                                  default: 0
    t.integer  "orders_count",                                                                 default: 0
    t.text     "introduction"
    t.boolean  "use_min_order_charge",                                                         default: false
    t.decimal  "min_order_charge",                                    precision: 8,  scale: 2
    t.decimal  "non_service_order_charge",                            precision: 8,  scale: 2, default: 0.0
    t.decimal  "delivery_radius",                                     precision: 6,  scale: 1, default: 1.5
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image",                                   limit: 191
    t.string   "charge_method",                           limit: 191,                          default: "by_time"
    t.integer  "left_order_count",                                                             default: 0
    t.string   "supported_order_types",                   limit: 191,                          default: "delivery,eat_in_hall,order_seat"
    t.boolean  "notify_new_order",                                                             default: true
    t.integer  "sms_msgs_count",                                                               default: 0
    t.boolean  "use_sms",                                                                      default: false
    t.integer  "max_sms_count",                                                                default: 0
    t.boolean  "use_sms_validation",                                                           default: false
    t.string   "sms_to",                                  limit: 191
    t.boolean  "use_scrachpad",                                                                default: false
    t.integer  "first_prize_possibility",                                                      default: 5
    t.integer  "second_prize_possibility",                                                     default: 10
    t.integer  "third_prize_possibility",                                                      default: 15
    t.string   "first_prize",                             limit: 191,                          default: "8折优惠"
    t.string   "second_prize",                            limit: 191,                          default: "9折优惠"
    t.string   "third_prize",                             limit: 191,                          default: "95折优惠"
    t.string   "no_prize",                                limit: 191,                          default: "谢谢惠顾"
    t.datetime "valid_before"
    t.decimal  "min_charge_for_scratch",                              precision: 8,  scale: 2, default: 10.0
    t.integer  "max_scratch_times_in_day",                                                     default: 5
    t.string   "supported_scratchpad_order_types",        limit: 191,                          default: "delivery,eat_in_hall,order_seat"
    t.integer  "min_order_time_gap",                                                           default: 30
    t.boolean  "check_stock",                                                                  default: true
    t.integer  "credits_given",                                                                default: 0
    t.integer  "credits_consume",                                                              default: 0
    t.integer  "position"
    t.boolean  "separate_notice_of_praise_and_new_order",                                      default: false
    t.datetime "deleted_at"
    t.decimal  "wallet_given",                                        precision: 8,  scale: 2, default: 0.0
    t.decimal  "wallet_consume",                                      precision: 8,  scale: 2, default: 0.0
    t.string   "product_list_style",                      limit: 191,                          default: "thumb"
    t.string   "delivery_radius_txt",                     limit: 191
    t.integer  "branch_type_id"
    t.integer  "branch_comments_count",                                                        default: 0
    t.decimal  "average_level",                                       precision: 2,  scale: 1, default: 5.0
    t.integer  "brand_chain_id"
    t.string   "type",                                    limit: 191
    t.integer  "branches_count",                                                               default: 0
    t.string   "supported_send_sms_order_types",          limit: 191
    t.string   "delivery_charge",                         limit: 191,                          default: "",                                null: false
    t.text     "terms"
    t.boolean  "allow_remind_order_msg",                                                       default: false
    t.boolean  "enabled_verify_service_periods",                                               default: false
    t.boolean  "fixed_delivery_time",                                                          default: false
    t.string   "rect_image",                              limit: 191
  end

  add_index "branches", ["brand_chain_id"], name: "index_branches_on_brand_chain_id", using: :btree
  add_index "branches", ["shop_id"], name: "index_branches_on_shop_id", using: :btree

  create_table "branches_zones", force: true do |t|
    t.integer "branch_id"
    t.integer "zone_id"
  end

  add_index "branches_zones", ["branch_id"], name: "index_branches_zones_on_branch_id", using: :btree
  add_index "branches_zones", ["zone_id"], name: "index_branches_zones_on_zone_id", using: :btree

  create_table "carts", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "line_items_count"
    t.integer  "shop_id"
    t.string   "user_id",          limit: 191
    t.integer  "branch_id"
  end

  add_index "carts", ["branch_id"], name: "index_carts_on_branch_id", using: :btree
  add_index "carts", ["shop_id"], name: "index_carts_on_shop_id", using: :btree
  add_index "carts", ["user_id"], name: "index_carts_on_user_id", using: :btree

  create_table "categories", force: true do |t|
    t.string   "name",        limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "position",                default: 0
    t.integer  "category_id",             default: 0, null: false
  end

  add_index "categories", ["branch_id"], name: "index_categories_on_branch_id", using: :btree
  add_index "categories", ["category_id"], name: "index_categories_on_category_id", using: :btree
  add_index "categories", ["shop_id"], name: "index_categories_on_shop_id", using: :btree

  create_table "categories_products", id: false, force: true do |t|
    t.integer "product_id"
    t.integer "category_id"
  end

  add_index "categories_products", ["category_id"], name: "index_categories_products_on_category_id", using: :btree
  add_index "categories_products", ["product_id"], name: "index_categories_products_on_product_id", using: :btree

  create_table "ckeditor_assets", force: true do |t|
    t.string   "data_file_name",    limit: 191, null: false
    t.string   "data_content_type", limit: 191
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "credits_logs", force: true do |t|
    t.string   "credit_log_type",              limit: 191
    t.integer  "credits"
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "credits_log_owner_id",                     default: 0,      null: false
    t.integer  "order_id"
    t.integer  "account_id"
    t.integer  "shop_credits_given_after"
    t.integer  "shop_credits_consume_after"
    t.integer  "branch_credits_given_after"
    t.integer  "branch_credits_consume_after"
    t.integer  "user_credits_balance_after"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "consume_log_id"
    t.integer  "angel_id"
    t.string   "credits_log_owner_type",       limit: 191, default: "User", null: false
    t.integer  "user_id"
  end

  add_index "credits_logs", ["angel_id"], name: "index_credits_logs_on_angel_id", using: :btree
  add_index "credits_logs", ["branch_id"], name: "index_credits_logs_on_branch_id", using: :btree
  add_index "credits_logs", ["credits_log_owner_id"], name: "index_credits_logs_on_owner_id", using: :btree
  add_index "credits_logs", ["credits_log_owner_type"], name: "index_credits_logs_on_credits_log_owner_type", using: :btree
  add_index "credits_logs", ["order_id"], name: "index_credits_logs_on_order_id", using: :btree
  add_index "credits_logs", ["shop_id"], name: "index_credits_logs_on_shop_id", using: :btree
  add_index "credits_logs", ["user_id"], name: "index_credits_logs_on_user_id", using: :btree

  create_table "currency_symbols", force: true do |t|
    t.string   "symbol",     limit: 191
    t.string   "decoration", limit: 191
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "currency_symbols", ["shop_id"], name: "index_currency_symbols_on_shop_id", using: :btree

  create_table "custom_ui_settings", force: true do |t|
    t.string   "branch_id",             limit: 191
    t.string   "order_delivery_btn",    limit: 191
    t.string   "order_eat_in_hall_btn", limit: 191
    t.string   "order_order_seat",      limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pay_on_receive",        limit: 191
    t.string   "pay_by_wallet",         limit: 191
    t.string   "pay_by_credits",        limit: 191
    t.string   "note_place_holder",     limit: 191
  end

  create_table "delivery_times", force: true do |t|
    t.integer  "branch_id"
    t.time     "delivery_time_start"
    t.time     "delivery_time_end"
    t.integer  "time_advance"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delivery_times", ["branch_id"], name: "index_delivery_times_on_branch_id", using: :btree

  create_table "delivery_zones", force: true do |t|
    t.string   "zone_name",  limit: 191
    t.integer  "branch_id"
    t.decimal  "charge",                 precision: 8, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "delivery_zones", ["branch_id"], name: "index_delivery_zones_on_branch_id", using: :btree

  create_table "events", force: true do |t|
    t.string   "event",             limit: 191
    t.string   "event_key",         limit: 191
    t.integer  "material_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
    t.boolean  "is_system_keyword"
    t.string   "system_keyword",    limit: 191
  end

  add_index "events", ["material_id"], name: "index_events_on_material_id", using: :btree
  add_index "events", ["shop_id"], name: "index_events_on_shop_id", using: :btree

  create_table "form_contents", force: true do |t|
    t.datetime "deleted_at"
    t.integer  "form_element_id"
    t.integer  "order_id"
    t.string   "label",           limit: 191
    t.string   "content",         limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "form_elements", force: true do |t|
    t.string   "type",            limit: 191
    t.string   "statement",       limit: 191
    t.string   "regex",           limit: 191
    t.integer  "sequence"
    t.integer  "form_element_id"
    t.integer  "branch_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
    t.boolean  "need"
    t.string   "placeholder",     limit: 191
  end

  create_table "frozen_assets", force: true do |t|
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.integer  "order_id"
    t.integer  "credits"
    t.decimal  "amount",                  precision: 8, scale: 2, default: 0.0
    t.string   "frozen_type", limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "frozen_assets", ["branch_id"], name: "index_frozen_assets_on_branch_id", using: :btree
  add_index "frozen_assets", ["order_id"], name: "index_frozen_assets_on_order_id", using: :btree
  add_index "frozen_assets", ["shop_id"], name: "index_frozen_assets_on_shop_id", using: :btree
  add_index "frozen_assets", ["user_id"], name: "index_frozen_assets_on_user_id", using: :btree

  create_table "guests", force: true do |t|
    t.string   "email",                  limit: 191, default: "", null: false
    t.string   "encrypted_password",     limit: 191, default: "", null: false
    t.string   "reset_password_token",   limit: 191
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 191
    t.string   "last_sign_in_ip",        limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "guests", ["email"], name: "index_guests_on_email", unique: true, using: :btree
  add_index "guests", ["reset_password_token"], name: "index_guests_on_reset_password_token", unique: true, using: :btree

  create_table "impressions", force: true do |t|
    t.string   "impressionable_type", limit: 191
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name",     limit: 191
    t.string   "action_name",         limit: 191
    t.string   "view_name",           limit: 191
    t.string   "request_hash",        limit: 191
    t.string   "ip_address",          limit: 191
    t.string   "session_hash",        limit: 191
    t.text     "message"
    t.text     "referrer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", length: {"impressionable_type"=>nil, "message"=>191, "impressionable_id"=>nil}, using: :btree
  add_index "impressions", ["user_id"], name: "index_impressions_on_user_id", using: :btree

  create_table "line_items", force: true do |t|
    t.integer  "product_id"
    t.integer  "cart_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quantity",   default: 0
  end

  add_index "line_items", ["cart_id"], name: "index_line_items_on_cart_id", using: :btree

  create_table "mail_settings", force: true do |t|
    t.boolean  "enable_mail",                      default: false
    t.string   "delivery_method",      limit: 191, default: "smtp"
    t.string   "address",              limit: 191
    t.integer  "port",                             default: 25
    t.string   "domain",               limit: 191
    t.string   "user_name",            limit: 191
    t.string   "password",             limit: 191
    t.string   "authentication",       limit: 191, default: "login"
    t.boolean  "enable_starttls_auto",             default: false
    t.string   "reply_to",             limit: 191
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "use_system_setting",               default: true
    t.boolean  "notify_shop_manager",              default: true
  end

  create_table "materials", force: true do |t|
    t.string   "msg_type",      limit: 191
    t.string   "material_name", limit: 191
    t.text     "content"
    t.string   "title",         limit: 191
    t.text     "description"
    t.string   "music_url",     limit: 191
    t.string   "hq_music_url",  limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
  end

  add_index "materials", ["shop_id"], name: "index_materials_on_shop_id", using: :btree

  create_table "menus", force: true do |t|
    t.string   "name",           limit: 191
    t.string   "event_type",     limit: 191
    t.string   "url",            limit: 191
    t.integer  "parent_menu_id"
    t.string   "menu_type",      limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
    t.integer  "shop_id"
    t.string   "keyword",        limit: 191
    t.integer  "material_id"
  end

  add_index "menus", ["material_id"], name: "index_menus_on_material_id", using: :btree
  add_index "menus", ["shop_id"], name: "index_menus_on_shop_id", using: :btree

  create_table "menus_system_configs", id: false, force: true do |t|
    t.integer "menu_id",          null: false
    t.integer "system_config_id", null: false
  end

  add_index "menus_system_configs", ["menu_id", "system_config_id"], name: "menu_id", unique: true, using: :btree

  create_table "message_threads", force: true do |t|
    t.datetime "last_update_time"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
  end

  add_index "message_threads", ["shop_id"], name: "index_message_threads_on_shop_id", using: :btree

  create_table "messages", force: true do |t|
    t.string   "msg_id",            limit: 191
    t.string   "to_user_name",      limit: 191
    t.string   "from_user_name",    limit: 191
    t.integer  "create_time"
    t.string   "msg_type",          limit: 191
    t.text     "content"
    t.string   "pic_url",           limit: 191
    t.decimal  "location_x",                    precision: 10, scale: 0
    t.decimal  "location_y",                    precision: 10, scale: 0
    t.integer  "scale"
    t.string   "label",             limit: 191
    t.string   "title",             limit: 191
    t.text     "description"
    t.string   "url",               limit: 191
    t.string   "event",             limit: 191
    t.string   "event_key",         limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "message_thread_id"
    t.string   "music_url",         limit: 191
    t.string   "hq_music_url",      limit: 191
    t.boolean  "is_leave_msg",                                           default: false
  end

  add_index "messages", ["is_leave_msg"], name: "index_messages_on_is_leave_msg", using: :btree
  add_index "messages", ["message_thread_id"], name: "index_messages_on_message_thread_id", using: :btree

  create_table "mobile_alipays", force: true do |t|
    t.string   "pid",               limit: 191
    t.string   "pkey",              limit: 191
    t.string   "email",             limit: 191
    t.boolean  "use_mobile_alipay",             default: false
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mobile_alipays", ["shop_id"], name: "index_mobile_alipays_on_shop_id", using: :btree

  create_table "order_items", force: true do |t|
    t.string   "name",         limit: 191
    t.decimal  "price",                    precision: 8, scale: 2
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quantity",                                         default: 0
    t.string   "product_unit", limit: 191,                         default: "份"
    t.integer  "product_id"
  end

  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree

  create_table "orders", force: true do |t|
    t.string   "name",             limit: 191
    t.string   "phone",            limit: 191
    t.string   "address",          limit: 191
    t.string   "note",             limit: 191
    t.decimal  "amount",                       precision: 8, scale: 2
    t.datetime "delivery_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
    t.integer  "state",                                                default: 1
    t.string   "user_id",          limit: 191
    t.integer  "branch_id"
    t.integer  "credits",                                              default: 0
    t.string   "order_type",       limit: 191,                         default: "delivery"
    t.integer  "guest_num"
    t.string   "desk_no",          limit: 191
    t.datetime "arrive_time"
    t.string   "pay_type",         limit: 191
    t.integer  "consume_credit",                                       default: 0
    t.decimal  "consume_wallet",               precision: 8, scale: 2, default: 0.0
    t.decimal  "cash_amount",                  precision: 8, scale: 2, default: 0.0
    t.integer  "angel_id"
    t.string   "type",             limit: 191
    t.integer  "delivery_zone_id"
    t.boolean  "is_paid",                                              default: false
    t.string   "nonce_str",        limit: 191
    t.datetime "last_remind_date"
    t.string   "delivery_period",  limit: 191
  end

  add_index "orders", ["angel_id"], name: "index_orders_on_angel_id", using: :btree
  add_index "orders", ["branch_id"], name: "index_orders_on_branch_id", using: :btree
  add_index "orders", ["delivery_zone_id"], name: "index_orders_on_delivery_zone_id", using: :btree
  add_index "orders", ["shop_id"], name: "index_orders_on_shop_id", using: :btree
  add_index "orders", ["state"], name: "index_orders_on_state", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "post_thread_labels", force: true do |t|
    t.string   "name",       limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "post_thread_labels_threads", force: true do |t|
    t.integer "post_thread_id"
    t.integer "post_thread_label_id"
  end

  create_table "post_threads", force: true do |t|
    t.string   "title",            limit: 191
    t.text     "content"
    t.datetime "last_requestd_at"
    t.integer  "requested_times"
    t.integer  "account_id"
    t.string   "workflow_state",   limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_published",                 default: false
  end

  add_index "post_threads", ["account_id"], name: "index_post_threads_on_account_id", using: :btree

  create_table "posts", force: true do |t|
    t.text     "content"
    t.integer  "account_id"
    t.integer  "post_thread_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["account_id"], name: "index_posts_on_account_id", using: :btree
  add_index "posts", ["post_thread_id"], name: "index_posts_on_post_thread_id", using: :btree

  create_table "printers", force: true do |t|
    t.string  "memberCode",     limit: 191
    t.string  "deviceNo",       limit: 191
    t.string  "apiKey",         limit: 191
    t.boolean "print_on_order",             default: true
    t.integer "branch_id"
    t.integer "copy_count",                 default: 1
    t.string  "phone",          limit: 191
    t.string  "printer_type",   limit: 191
    t.string  "name",           limit: 191
  end

  create_table "product_sliders", force: true do |t|
    t.string   "img",        limit: 191
    t.text     "desc"
    t.integer  "branch_id"
    t.integer  "position"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_sliders", ["branch_id"], name: "index_product_sliders_on_branch_id", using: :btree
  add_index "product_sliders", ["product_id"], name: "index_product_sliders_on_product_id", using: :btree

  create_table "product_units", force: true do |t|
    t.string   "name",       limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "branch_id"
    t.integer  "shop_id"
  end

  create_table "products", force: true do |t|
    t.string   "name",            limit: 191
    t.text     "description"
    t.decimal  "price",                       precision: 8, scale: 2, default: 0.0
    t.integer  "stock",                                               default: 1000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tag_id"
    t.integer  "shop_id"
    t.string   "product_type",    limit: 191,                         default: "NORMAL"
    t.string   "pic",             limit: 191
    t.integer  "branch_id"
    t.integer  "position",                                            default: 1
    t.string   "product_unit",    limit: 191,                         default: "份"
    t.datetime "deleted_at"
    t.decimal  "credit_times",                precision: 8, scale: 2, default: 1.0
    t.boolean  "down",                                                default: false,    null: false
    t.boolean  "choice",                                              default: false,    null: false
    t.integer  "choice_position",                                     default: 1,        null: false
  end

  add_index "products", ["branch_id"], name: "index_products_on_branch_id", using: :btree
  add_index "products", ["choice"], name: "index_products_on_choice", using: :btree
  add_index "products", ["pic"], name: "index_products_on_pic", using: :btree
  add_index "products", ["shop_id"], name: "index_products_on_shop_id", using: :btree

  create_table "products_subjects", force: true do |t|
    t.integer  "product_id"
    t.integer  "subject_id"
    t.datetime "deleted_at"
  end

  add_index "products_subjects", ["product_id"], name: "index_products_subjects_on_product_id", using: :btree
  add_index "products_subjects", ["subject_id"], name: "index_products_subjects_on_subject_id", using: :btree

  create_table "promotion_configs", force: true do |t|
    t.integer "promotion_id"
    t.string  "name",              limit: 191
    t.string  "key",               limit: 191
    t.string  "config_value_type", limit: 191
    t.boolean "config_value_b"
    t.integer "config_value_i"
    t.string  "config_value_str",  limit: 191
    t.decimal "config_value_d",                precision: 10, scale: 0
  end

  add_index "promotion_configs", ["key"], name: "index_promotion_configs_on_key", using: :btree
  add_index "promotion_configs", ["promotion_id"], name: "index_promotion_configs_on_promotion_id", using: :btree

  create_table "promotion_details", force: true do |t|
    t.integer "product_id"
    t.decimal "price",        precision: 8, scale: 2
    t.integer "promotion_id"
  end

  create_table "promotion_logs", force: true do |t|
    t.integer  "article_id"
    t.integer  "shop_id"
    t.string   "sharer",           limit: 191
    t.string   "browser",          limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sharer_nickname",  limit: 191
    t.string   "browser_nickname", limit: 191
  end

  add_index "promotion_logs", ["article_id"], name: "index_promotion_logs_on_article_id", using: :btree
  add_index "promotion_logs", ["shop_id"], name: "index_promotion_logs_on_shop_id", using: :btree

  create_table "promotions", force: true do |t|
    t.integer  "branch_id"
    t.string   "key",         limit: 191
    t.string   "name",        limit: 191
    t.text     "description"
    t.string   "image",       limit: 191
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "promotions", ["branch_id"], name: "index_promotions_on_branch_id", using: :btree
  add_index "promotions", ["key"], name: "index_promotions_on_key", using: :btree

  create_table "push_regs", force: true do |t|
    t.string   "registration_id", limit: 191
    t.integer  "binder_id"
    t.string   "binder_type",     limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "push_regs", ["binder_id", "binder_type"], name: "index_push_regs_on_binder_id_and_binder_type", using: :btree

  create_table "reports", force: true do |t|
    t.string   "title",      limit: 191
    t.string   "author",     limit: 191
    t.text     "content"
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reports", ["shop_id"], name: "index_reports_on_shop_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name",          limit: 191
    t.integer  "resource_id"
    t.string   "resource_type", limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "scrachpads", force: true do |t|
    t.string   "card_result",  limit: 191
    t.datetime "valid_before"
    t.string   "user_id",      limit: 191
    t.string   "branch_id",    limit: 191
    t.string   "shop_id",      limit: 191
    t.boolean  "is_used",                  default: false
    t.boolean  "is_opened",                default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_id"
    t.datetime "used_time"
    t.datetime "deleted_at"
  end

  add_index "scrachpads", ["user_id"], name: "index_scrachpads_on_user_id", using: :btree

  create_table "service_periods", force: true do |t|
    t.integer  "branch_id"
    t.time     "service_period_start"
    t.time     "service_period_end"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "service_periods", ["branch_id"], name: "index_service_periods_on_branch_id", using: :btree

  create_table "service_products", force: true do |t|
    t.string   "subject",                 limit: 191
    t.decimal  "price",                               precision: 8, scale: 2
    t.integer  "quantity",                                                    default: 1
    t.text     "description"
    t.integer  "position",                                                    default: 1
    t.string   "product_type",            limit: 191
    t.string   "available_shop_versions", limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_sale_orders", force: true do |t|
    t.string   "subject",            limit: 191
    t.string   "out_trade_no",       limit: 191
    t.decimal  "price",                          precision: 8,  scale: 2
    t.integer  "quantity"
    t.decimal  "discount",                       precision: 10, scale: 0
    t.string   "workflow_state",     limit: 191
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "service_product_id"
  end

  add_index "service_sale_orders", ["service_product_id"], name: "index_service_sale_orders_on_service_product_id", using: :btree
  add_index "service_sale_orders", ["shop_id"], name: "index_service_sale_orders_on_shop_id", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", limit: 191, null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "shops", force: true do |t|
    t.string   "name",                              limit: 191
    t.string   "slug",                              limit: 191
    t.boolean  "is_open",                                                                default: true
    t.datetime "expiration_time"
    t.integer  "orders_count",                                                           default: 0
    t.decimal  "income",                                        precision: 10, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "telephone",                         limit: 191
    t.integer  "accounts_count",                                                         default: 0
    t.integer  "users_count",                                                            default: 0
    t.text     "introduction"
    t.integer  "max_branches_count",                                                     default: 1
    t.string   "image",                             limit: 191
    t.boolean  "use_credits",                                                            default: true
    t.decimal  "money_for_each_credit",                         precision: 8,  scale: 2, default: 1.0
    t.string   "default_reply_content_type",        limit: 191,                          default: "news"
    t.string   "charge_method",                     limit: 191,                          default: "by_time"
    t.integer  "left_order_count",                                                       default: 0
    t.text     "welcome_msg"
    t.boolean  "use_sms",                                                                default: false
    t.integer  "max_sms_count",                                                          default: 0
    t.boolean  "use_sms_validation",                                                     default: false
    t.integer  "sms_msgs_count",                                                         default: 0
    t.integer  "max_validation_code_times_in_day",                                       default: 5
    t.integer  "credits_given",                                                          default: 0
    t.integer  "credits_consume",                                                        default: 0
    t.boolean  "support_credits_pay"
    t.integer  "credit_for_each_money",                                                  default: 1
    t.decimal  "wallet_given",                                  precision: 8,  scale: 2, default: 0.0
    t.decimal  "wallet_consume",                                precision: 8,  scale: 2, default: 0.0
    t.boolean  "support_wallet_pay"
    t.boolean  "enable_new_version",                                                     default: true
    t.boolean  "hide_support_company",                                                   default: false
    t.boolean  "award_credits_at_follow",                                                default: false
    t.integer  "award_credits",                                                          default: 0
    t.integer  "max_branch_sliders",                                                     default: 1
    t.integer  "branch_comments_count",                                                  default: 0
    t.integer  "least_promotion_number"
    t.string   "workflow_state",                    limit: 191
    t.string   "qrcode",                            limit: 191
    t.string   "subdomain",                         limit: 191
    t.integer  "product_image_limit",                                                    default: 5
    t.integer  "product_slider_limit",                                                   default: 1
    t.boolean  "support_auto_buy_service",                                               default: false
    t.string   "support_link_name",                 limit: 191
    t.string   "support_link",                      limit: 191
    t.string   "domain",                            limit: 191,                          default: "",        null: false
    t.boolean  "validated_domain",                                                       default: false,     null: false
    t.text     "copy_right_footer"
    t.boolean  "enable_foreign_currency",                                                default: false
    t.string   "foreign_currency_symbol",           limit: 191
    t.string   "reply_num_of_orders",               limit: 191
    t.string   "aid",                               limit: 191
    t.boolean  "enable_unrecognized_reply_message",                                      default: true
    t.boolean  "show_detail_for_branch",                                                 default: false
  end

  add_index "shops", ["slug"], name: "index_shops_on_slug", unique: true, using: :btree

  create_table "site_configs", force: true do |t|
    t.string   "key",          limit: 191
    t.string   "display_name", limit: 191
    t.string   "value_type",   limit: 191
    t.string   "value_s",      limit: 191
    t.boolean  "value_b"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sms_msgs", force: true do |t|
    t.string   "to",                 limit: 191
    t.string   "body",               limit: 191
    t.string   "sms_message_id",     limit: 191
    t.string   "date_created",       limit: 191
    t.string   "msg_type",           limit: 191
    t.integer  "branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_id",            limit: 191
    t.string   "order_msg_type",     limit: 191, default: "order"
    t.integer  "sms_msg_owner_id"
    t.string   "sms_msg_owner_type", limit: 191
  end

  add_index "sms_msgs", ["date_created"], name: "index_sms_msgs_on_date_created", using: :btree
  add_index "sms_msgs", ["sms_message_id"], name: "index_sms_msgs_on_sms_message_id", using: :btree
  add_index "sms_msgs", ["to"], name: "index_sms_msgs_on_to", using: :btree

  create_table "subjects", force: true do |t|
    t.string   "name",       limit: 191
    t.string   "sale",       limit: 191
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "deleted_at"
    t.string   "show_image", limit: 191
    t.string   "image",      limit: 191
    t.integer  "branch_id"
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_configs", force: true do |t|
    t.string   "url",                         limit: 191
    t.string   "token",                       limit: 191
    t.string   "appId",                       limit: 191
    t.string   "appSecret",                   limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "my_fake_id",                  limit: 191
    t.integer  "shop_id"
    t.boolean  "gonghao_type"
    t.string   "public_account_name",         limit: 191
    t.boolean  "be_verified",                             default: false
    t.boolean  "support_weixin_pay",                      default: false
    t.string   "paySignKey",                  limit: 191
    t.string   "partnerId",                   limit: 191
    t.string   "partnerKey",                  limit: 191
    t.string   "access_token",                limit: 191
    t.datetime "last_update_access_token_at"
  end

  add_index "system_configs", ["my_fake_id"], name: "index_system_configs_on_my_fake_id", using: :btree
  add_index "system_configs", ["shop_id"], name: "index_system_configs_on_shop_id", using: :btree

  create_table "tags", force: true do |t|
    t.string   "name",       limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
    t.integer  "branch_id"
  end

  add_index "tags", ["branch_id"], name: "index_tags_on_branch_id", using: :btree
  add_index "tags", ["shop_id"], name: "index_tags_on_shop_id", using: :btree

  create_table "tenpays", force: true do |t|
    t.integer  "shop_id"
    t.string   "pid",        limit: 191
    t.string   "pkey",       limit: 191
    t.boolean  "use_tenpay",             default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tenpays", ["shop_id"], name: "index_tenpays_on_shop_id", using: :btree

  create_table "themes", force: true do |t|
    t.string   "background_color",  limit: 191
    t.string   "text_color",        limit: 191
    t.string   "header_bg_color",   limit: 191
    t.string   "header_text_color", limit: 191
    t.string   "navbar_bg_color",   limit: 191
    t.string   "navbar_text_color", limit: 191
    t.string   "menu_bg_color",     limit: 191
    t.string   "menu_text_color",   limit: 191
    t.string   "theme_type",        limit: 191, default: "theme_system"
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "themes", ["shop_id"], name: "index_themes_on_shop_id", using: :btree

  create_table "trade_rels", id: false, force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "branch_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trade_rels", ["branch_id"], name: "index_trade_rels_on_branch_id", using: :btree
  add_index "trade_rels", ["user_id"], name: "index_trade_rels_on_user_id", using: :btree

  create_table "trades", force: true do |t|
    t.string   "trade_id",     limit: 191
    t.string   "trade_type",   limit: 191
    t.text     "query"
    t.text     "body"
    t.string   "partner",      limit: 191
    t.decimal  "total_fee",                precision: 10, scale: 0
    t.string   "out_trade_no", limit: 191
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transaction_logs", force: true do |t|
    t.text     "description"
    t.string   "buyer_email",           limit: 191
    t.integer  "shop_id"
    t.integer  "service_sale_order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transaction_logs", ["service_sale_order_id"], name: "index_transaction_logs_on_service_sale_order_id", using: :btree
  add_index "transaction_logs", ["shop_id"], name: "index_transaction_logs_on_shop_id", using: :btree

  create_table "validated_phones", force: true do |t|
    t.string   "user_id",        limit: 191
    t.string   "phone",          limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",           limit: 191
    t.integer  "phone_owner_id",             default: 0, null: false
  end

  add_index "validated_phones", ["user_id"], name: "index_validated_phones_on_user_id", using: :btree

  create_table "validation_codes", force: true do |t|
    t.string   "user_id",       limit: 191
    t.string   "code",          limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",          limit: 191
    t.integer  "code_owner_id",             default: 0, null: false
  end

  add_index "validation_codes", ["user_id"], name: "index_validation_codes_on_user_id", using: :btree

  create_table "vip_levels", force: true do |t|
    t.integer  "shop_id"
    t.string   "name",             limit: 191
    t.decimal  "discount",                     precision: 4, scale: 2, default: 1.0
    t.integer  "base_users_count",                                     default: 0
    t.integer  "integer",                                              default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "auto_upgrade",                                         default: false
    t.decimal  "min_total_amount",             precision: 8, scale: 2
  end

  add_index "vip_levels", ["shop_id"], name: "index_vip_levels_on_shop_id", using: :btree

  create_table "wallet_logs", force: true do |t|
    t.integer  "wallet_log_owner_id",                                             default: 0,      null: false
    t.integer  "shop_id"
    t.integer  "branch_id"
    t.string   "wallet_log_type",             limit: 191
    t.decimal  "money",                                   precision: 8, scale: 2
    t.integer  "account_id"
    t.text     "note"
    t.decimal  "shop_wallet_given_after",                 precision: 8, scale: 2, default: 0.0
    t.decimal  "shop_wallet_consume_after",               precision: 8, scale: 2, default: 0.0
    t.decimal  "branch_wallet_given_after",               precision: 8, scale: 2, default: 0.0
    t.decimal  "branch_wallet_consume_after",             precision: 8, scale: 2, default: 0.0
    t.decimal  "user_wallet_balance_after",               precision: 8, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_id"
    t.integer  "recharge_log_id"
    t.integer  "angel_id"
    t.string   "wallet_log_owner_type",       limit: 191,                         default: "User", null: false
    t.integer  "user_id"
  end

  add_index "wallet_logs", ["account_id"], name: "index_wallet_logs_on_account_id", using: :btree
  add_index "wallet_logs", ["angel_id"], name: "index_wallet_logs_on_angel_id", using: :btree
  add_index "wallet_logs", ["branch_id"], name: "index_wallet_logs_on_branch_id", using: :btree
  add_index "wallet_logs", ["order_id"], name: "index_wallet_logs_on_order_id", using: :btree
  add_index "wallet_logs", ["shop_id"], name: "index_wallet_logs_on_shop_id", using: :btree
  add_index "wallet_logs", ["user_id"], name: "index_wallet_logs_on_user_id", using: :btree
  add_index "wallet_logs", ["wallet_log_owner_id"], name: "index_wallet_logs_on_owner_id", using: :btree
  add_index "wallet_logs", ["wallet_log_owner_type"], name: "index_wallet_logs_on_wallet_log_owner_type", using: :btree

  create_table "weixinpay_feedbacks", force: true do |t|
    t.string   "feedback_id", limit: 191
    t.string   "openid",      limit: 191
    t.string   "appid",       limit: 191
    t.string   "trade_id",    limit: 191
    t.text     "body"
    t.string   "msg_type",    limit: 191
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "weixinpay_warnings", force: true do |t|
    t.string   "error_type",    limit: 191
    t.string   "appId",         limit: 191
    t.text     "description"
    t.text     "alarm_content"
    t.text     "body"
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zones", force: true do |t|
    t.string   "name",           limit: 191
    t.integer  "parent_zone_id"
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "zones", ["parent_zone_id"], name: "index_zones_on_parent_zone_id", using: :btree
  add_index "zones", ["shop_id"], name: "index_zones_on_shop_id", using: :btree

end
