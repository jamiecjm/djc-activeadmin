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
	scope :not_cancelled, -> { joins(:sale).where('sales.status != ?', 2) }

	belongs_to :user, optional: true
	belongs_to :sale, optional: true
	has_one :team, through: :user
	has_one :project, through: :sale
	has_one :unit, through: :sale

	validates :user_id, presence: true, unless: proc { other_user.present? }
	validates :percentage, presence: true
	validates :other_user, presence: true, unless: proc { user_id.present? }

	accepts_nested_attributes_for :user, :allow_destroy => true, reject_if: proc { |attributes| attributes['prefered_name'].blank?}


	def self.TotalNetValue
		self.all.to_a.pluck(:nett_value).inject(:+)
	end

	def self.TotalComm
		self.all.to_a.pluck(:comm).inject(:+)
	end

	def self.TotalSPA
		self.all.to_a.pluck(:spa).inject(:+)
	end

	def self.TotalSales
		self.active_sv.count
	end

	def recalculate
		self.update(spa:sale.spa_price*self.percentage/100, nett_value:sale.nett_price*self.percentage/100, comm:sale.comm*self.percentage/100)
	end

end
