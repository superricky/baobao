class Printer < ActiveRecord::Base

  FEIYIN_PRINTER = 'feiyin'

  PRINTERTYPES = [[I18n.t('printer.feiyin'), FEIYIN_PRINTER]]

  validates :deviceNo, :apiKey, :memberCode, presence:true, if: :use_feiyin_printer?
  validates :deviceNo, uniqueness:{:scope=>:branch_id}, if: :use_feiyin_printer?
  validates :phone, presence:true, format: {with: VALID_PHONE_REGEX}, if: :print_on_order
  validates_numericality_of :copy_count, :greater_than => 0, :less_than => 10
  validates :name, presence: true, uniqueness:{:scope=>:branch_id}
  belongs_to :branch
  has_one :shop, through: :branch

  scope :get_feiyin_printers, ->{where(:print_on_order=>true, :printer_type=>Printer::FEIYIN_PRINTER)}

  def use_feiyin_printer?
    print_on_order and printer_type == FEIYIN_PRINTER
  end
end
