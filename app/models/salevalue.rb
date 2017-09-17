# == Schema Information
#
# Table name: salevalues
#
#  id         :integer          not null, primary key
#  percentage :float
#  nett_value :float
#  spa        :float
#  comm       :float
#  user_id    :integer
#  sale_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  other_user :string
#
# Indexes
#
#  index_salevalues_on_sale_id  (sale_id)
#  index_salevalues_on_user_id  (user_id)
#

class Salevalue < ApplicationRecord

	scope :team, -> {where(other_user: nil)}
	scope :other_team, -> {where.not(other_user: nil)}

	belongs_to :user, optional: true
	belongs_to :sale, optional: true
	has_one :project, through: :sale
	has_one :unit, through: :sale

	accepts_nested_attributes_for :user, :allow_destroy => true, reject_if: proc { |attributes| attributes['prefered_name'].blank?}

	def self.active_sv
		self.joins(:sale).where("sales.status"=>["Booked","Done"])
	end

	def self.TotalNetValue
		self.active_sv.sum(:nett_value)
	end

	def self.TotalComm
		self.active_sv.sum(:comm)
	end

	def self.TotalSPA
		self.active_sv.sum(:spa)
	end

	def self.TotalSales
		self.active_sv.count
	end

	def recalculate(unit)
		self.update(spa:unit.spa_price*self.percentage/100, nett_value:unit.nett_price*self.percentage/100, comm:unit.comm*self.percentage/100)
	end

end
