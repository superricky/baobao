class MemberOld < ActiveRecord::Base
  self.table_name = "members"
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  belongs_to :shop
  has_many :orders, class_name: :OrderWebstore, foreign_key: :user_id
  devise :database_authenticatable, :registerable, :confirmable, :recoverable,
    :rememberable, :trackable, authentication_keys: [:email, :shop_id]
  has_one :validation_code, as: :code_owner, dependent: :destroy
  has_many :validated_phones, as: :phone_owner, dependent: :destroy
  has_many :sms_msgs, as: :sms_msg_owner
  #devise/models/validatable.rb
  @@email_regexp = /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
  mattr_accessor :email_regexp
  @@password_length = 6..128
  mattr_accessor :password_length
  extend ClassMethods
  validates_uniqueness_of :email, allow_blank: true, if: :email_changed?, scope: :shop_id, case_sensitive: false
  validates_presence_of   :email, :if => :email_required?
  validates_format_of     :email, :with  => email_regexp, :allow_blank => true, :if => :email_changed?
  validates_presence_of     :password, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?
  validates_length_of       :password, :within => password_length, :allow_blank => true
  validates :name, presence: true
  attr_accessor :host
  protected
    def password_required?
      !persisted? || !password.nil? || !password_confirmation.nil?
    end

    def email_required?
      true
    end

    module ClassMethods
      Devise::Models.config(self, :email_regexp, :password_length)
    end
    #devise/models/validatable.rb

  public
    def get_validation_code
      if self.validation_code.present?  and self.validation_code.is_activated?
        self.validation_code
      elsif validation_code.present?
        self.validation_code.destroy
        self.create_validation_code
      else
        self.create_validation_code
      end
    end
end
