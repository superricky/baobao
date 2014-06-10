#encoding: utf-8
require 'file_size_validator'
require 'csv'
class Product < ActiveRecord::Base
    acts_as_paranoid
    has_many :line_items, dependent: :destroy
    has_and_belongs_to_many :categories, -> { uniq}
    belongs_to :tag
    validates :name, presence: true, :uniqueness_without_deleted => {:message=>I18n.t('same product name already exist'),:scope=>:branch_id}
    validates :shop, presence: true
    validates :branch, presence: true
    before_destroy :ensure_not_referenced_by_any_line_items
    belongs_to :shop
    belongs_to :branch, counter_cache: true
    has_many :promotion_details, inverse_of: :product, dependent: :destroy
    has_many :promotions, through: :promotion_details
    has_many :order_items
    validates :product_unit, presence:true
    validates :price, :categories, presence: true
    require 'carrierwave/orm/activerecord'
      mount_uploader :image, ProductImageUploader,:mount_on=>:pic
    skip_callback :save, :after, :store_image!, if: :is_pic_url_dup?
    skip_callback :save, :after, :remove_previously_stored_image, if: :is_pic_url_dup?
    skip_callback :commit, :after, :remove_image!, if: :is_pic_url_dup?
    validates :image,
    :file_size => {
      :maximum => 0.5.megabytes.to_i
    }, if: :pic_already_exist?
    default_scope {order('position ASC')}
    validate :check_image_count, if: "shop.is_multipe_base_version?"
    scope :imagable, ->{ where("pic IS NOT NULL")}

    acts_as_list scope: :branch

    attr_accessor :original_price

    def check_image_count
      if self.pic.nil? and self.image.present?
        self.errors.add(:image, "上传产品图像数量超过最大限制，您最多允许每个商户上传#{self.shop.product_image_limit}张图片") if self.shop.is_multipe_base_version? and (self.branch.products.imagable.count > self.shop.product_image_limit)
      end
    end
    #skip_callback :save, :after, :store_avatar!, if: :pic_is_exist?
    def original_price
      self.read_attribute(:price)
    end

    #def original_pic_url
    #  self.read_attribute(:pic)
    #end
    def is_pic_url_dup?
      self.class.where("pic = ? and id != ?", pic, id).count > 0
    end

    def pic_already_exist?
      self.class.where(:pic => pic).count>0
    end

    def credits_for_each_product
      if self.shop.use_credits and self.shop.money_for_each_credit > 0.0
        (self.price/self.shop.money_for_each_credit).to_i
      else
        0
      end
    end

    # def category_ids
    #   self.categories.map(&:id)
    # end

    def category_ids=(ids)
      self.categories.clear
      self.categories << Category.find(ids[0..-1]) rescue nil
    end

    def price(user=nil)
      if self.original_price.present?
        OrderStrategy::product_price(self, user)
      end
    end

    def price_with_promotion_details(user=nil, promotion_details)
      if promotion_details.present?
        promotion_detail = promotion_details.select{|promotion_detail| promotion_detail.product_id == self.id}.first rescue nil
      end
      OrderStrategy::product_price_with_promotion_detail(self, user, promotion_detail)
    end

    def self.to_csv(options = {})
      CSV.generate(options) do |csv|
        csv << [ "ID", "菜名", "菜价", "单位", "库存", "分类名", "标签", "描述"]
        all.each do |product|
          categories = product.categories.collect do |c|
            c.category_id == 0 ? c.name : "#{c.category.name}*#{c.name}"
          end
          categories = categories.join '|' rescue nil
          tag = product.tag.name rescue nil
          csv << [product.id, product.name, product.price, product.product_unit, product.stock, categories, tag, product.description]
        end
      end
    end

    def self.update_and_create_from_file(file, branch)
      begin
        csv = CSV.parse(File.open(file.path, 'r:gb18030:utf-8'){|f| f.read}, col_sep: ",")
      rescue => e
        csv = CSV.parse(File.open(file.path, 'r:utf-8'){|f| f.read}, col_sep: ",")
      end
      csv.slice!(0)
      csv.each do |row|
        product = branch.products.find(row[0]) rescue nil
        unless product.present?
          product = branch.products.find_by_name(row[1]) rescue nil
        end
        if product.present?
          product.name = row[1]
          product.price = row[2]
          product.product_unit = row[3]
          product.stock = row[4]
          product.tag = branch.tags.find_or_create_by(name: row[6])
          product.description = row[7]
        else
          new_product = branch.products.build(
            name: row[1],
            price: row[2],
            stock: row[4].present? ? row[4] : 1000 ,
            product_unit: row[3],
            tag: branch.tags.find_or_create_by(name: row[6]),
            shop: branch.shop,
            description: row[7]
          )
        end
        current_product = product || new_product
        current_product.categories.clear
        if row[5]
          row[5].split("|").each do |names|
            names = names.split "*"
            name = names.first
            sub_name = names.last if names.first != names.last
            category = branch.categories.find_or_create_by(name: name, shop_id: branch.shop_id, category_id: 0)
            sub_category = branch.categories.find_or_create_by(name: sub_name, shop_id: branch.shop_id, category_id: category.id) if sub_name
            current_product.categories << (sub_category ? sub_category : category)
          end
        end
        current_product.save!
      end
    end

    def self.set_shelves(ids)
      self.where(id: ids).update_all down: true
    end

    def self.set_addeds(ids)
      self.where(id: ids).update_all down: false
    end

    private
    def ensure_not_referenced_by_any_line_items
      if line_items.empty?
        return true
      else
        errors.add(:base, I18n.t('some carts are using this product'))
        return false
      end
    end

    def self.populars_of_week_by_branch(branch)
      joins(:order_items).
      where("order_items.created_at >= ? and products.branch_id = ?", 7.days.ago.strftime("%F"), branch.id).
      group("products.id").order("count(products.id) desc")
    end
end
