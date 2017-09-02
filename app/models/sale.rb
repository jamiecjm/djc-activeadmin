# == Schema Information
#
# Table name: sales
#
#  id            :integer          not null, primary key
#  date          :date
#  buyer         :string
#  project_id    :integer
#  unit_id       :integer
#  status        :integer          default("Booked")
#  package       :string
#  remark        :string
#  spa_sign_date :date
#  la_date       :date
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  commission_id :integer
#
# Indexes
#
#  index_sales_on_commission_id  (commission_id)
#  index_sales_on_date           (date)
#  index_sales_on_project_id     (project_id)
#  index_sales_on_unit_id        (unit_id)
#

class Sale < ApplicationRecord
  
  has_many :users, :through => :salevalues
  belongs_to :project, optional: true
  belongs_to :commission, optional: true
  belongs_to :unit, optional: true, :dependent => :destroy
  has_many :teams, through: :users
  has_many :salevalues, :dependent => :destroy
  has_many :salevalues2, class_name: "Salevalue", :dependent => :destroy

  after_create :after_save_action, :unless => :skip_callback
  before_validation :set_commission_id, :unless => :skip_callback

  attr_accessor :skip_callback

  validates :commission_id, presence: {message: "is not available for that date. Check with your leader for more details."}

  accepts_nested_attributes_for :salevalues, :allow_destroy => true, reject_if: proc { |attributes| attributes['user_id'].blank? ||  attributes['percentage'].blank?}
  accepts_nested_attributes_for :salevalues2, :allow_destroy => true, reject_if: proc { |attributes| attributes['percentage'].blank?}
  accepts_nested_attributes_for :unit

  enum status: ["Booked","Done","Canceled"]

  def self.not_canceled
    self.where.not(status: "Canceled")
  end

  def self.TotalNetValue
    self.where(status: ["Done","Booked"]).joins(:unit).sum(:nett_price)
  end

  def self.TotalComm
    self.where(status: ["Done","Booked"]).joins(:unit).sum("units.comm")
  end

  def self.TotalSPA
    self.where(status: ["Done","Booked"]).joins(:unit).sum(:spa_price)
  end

  def self.TotalSales
    self.where(status: ["Done","Booked"]).count
  end

  def calculate   
    comm = self.commission
    unit = self.unit
    unit.update(sale_id: self.id,project_id: self.project_id,comm: comm.percentage/100*unit.nett_price*0.94,comm_percentage: comm.percentage)
    self.salevalues.each do |sv|
      sv.recalculate(unit)
      # sv.user.recalculate
    end 
  end

  def after_save_action
    self.update(buyer: self.buyer.titleize,unit_id: unit.id)
    User.merge
    self.calculate
  end

  def set_commission_id
    commission = self.project.commission(self.date)
    if commission.present?
      self.commission_id = commission.id 
    else
      self.commission_id = nil
    end
  end



end
