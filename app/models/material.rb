class Material < ActiveRecord::Base

    PROMOTION_TYPE = "promotion"
    MATERIAL_NEWS_TYPE = "news"
    MATERIAL_TEXT_TYPE = "text"
    MATERIAL_MUSIC_TYPE = "music"
    validates :material_name, :msg_type, presence: true, on: :update
    validates :content, presence: true, if: :is_text?
    validates :title, :music_url, presence: true, if: :is_music?
    validates :material_name, uniqueness: { :scope=>:shop_id }, on: :update
    validates_associated :articles
    has_many :articles, -> { order("position ASC") }, dependent: :destroy, as: :owner
    has_many :events, dependent: :destroy
    has_many :menus, dependent: :destroy
    belongs_to :shop

    default_scope -> {order("created_at DESC")}

    before_save :remove_unused_attribute
    public
      def is_text?
        msg_type == MATERIAL_TEXT_TYPE
      end

      def is_music?
        msg_type == MATERIAL_MUSIC_TYPE
      end

      def is_news?
        msg_type == MATERIAL_NEWS_TYPE
      end

      def is_promotion?
        msg_type == PROMOTION_TYPE
      end

      def self.valid_materials(all_materials)
        materials = []
        all_materials.each do |material|
          if material.valid?
            materials << material
          else
            material.destroy
          end
        end
        materials
      end

    private
      def remove_unused_attribute
        if is_text?
          title = nil
          description = nil
          music_url = nil
          hq_music_url = nil
          articles.delete_all unless articles.nil?
          articles = []
        elsif is_music?
          content = nil
          articles.delete_all unless articles.nil?
          articles = []
        elsif is_news?
          content = nil
          title = nil
          description = nil
          music_url = nil
          hq_music_url = nil
        end
      end


end
