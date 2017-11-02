# == Schema Information
#
# Table name: sales
#
#  id              :integer          not null, primary key
#  date            :date
#  buyer           :string
#  project_id      :integer
#  unit_id         :integer
#  status          :integer          default("Booked")
#  package         :string
#  remark          :string
#  spa_sign_date   :date
#  la_date         :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  commission_id   :integer
#  unit_no         :string
#  size            :integer
#  nett_price      :float
#  spa_price       :float
#  comm            :float
#  comm_percentage :float
#
# Indexes
#
#  index_sales_on_commission_id  (commission_id)
#  index_sales_on_date           (date)
#  index_sales_on_project_id     (project_id)
#  index_sales_on_unit_id        (unit_id)
#

class Sale < ApplicationRecord

  scope :not_canceled, -> {where.not(status: "Canceled")}

  has_many :users, :through => :salevalues
  belongs_to :project, optional: true
  belongs_to :commission, optional: true
  belongs_to :unit, optional:true, :dependent => :destroy
  has_many :teams, through: :users
  has_many :salevalues, -> {team}, :dependent => :destroy
  has_many :salevalues2, -> {other_team}, class_name: "Salevalue", :dependent => :destroy

  after_create :after_save_action, :unless => :skip_callback
  before_validation :set_commission_id, :unless => :skip_callback

  attr_accessor :skip_callback

  validates :commission_id, presence: {message: "is not available for that date. Check with your leader for more details."}

  accepts_nested_attributes_for :salevalues, :allow_destroy => true, reject_if: proc { |attributes| attributes['user_id'].blank? ||  attributes['percentage'].blank?}
  accepts_nested_attributes_for :salevalues2, :allow_destroy => true, reject_if: proc { |attributes| attributes['percentage'].blank?}
  accepts_nested_attributes_for :unit

  enum status: ["Booked","Done","Canceled"]

  def self.TotalNetValue
    self.not_canceled.to_a.pluck(:nett_price).inject(:+)
  end

  def self.TotalComm
    self.not_canceled.to_a.pluck(:comm).inject(:+)
  end

  def self.TotalSPA
    self.not_canceled.to_a.pluck(:spa_price).inject(:+)
  end

  def self.TotalSales
    self.not_canceled.to_a.length
  end

  def calculate
    comm = commission
    update(comm: comm.percentage/100*nett_price*0.94,comm_percentage: comm.percentage)
    salevalues.map(&:recalculate)
  end

  def after_save_action
    update(buyer: self.buyer.titleize)
    User.merge
    calculate
  end

  def set_commission_id
    commission = project.commission(self.date)
    if commission.present?
      self.commission_id = commission.id
    end
  end



end
