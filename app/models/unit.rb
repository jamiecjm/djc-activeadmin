class Unit < ApplicationRecord
	belongs_to :sale, optional: true
	belongs_to :project, optional: true

	before_save :upcase

	private

	def upcase
		self.unit_no = self.unit_no.upcase if self.unit_no.present?
		self.nett_price.to_s.gsub!(/[^\d\.]/, '')
		self.size.to_s.gsub!(/[^\d\.]/, '')
		self.spa_price.to_s.gsub!(/[^\d\.]/, '')
	end


end

# == Schema Information
#
# Table name: units
#
#  id              :integer          not null, primary key
#  unit_no         :string
#  size            :integer
#  nett_price      :float
#  spa_price       :float
#  comm            :float
#  comm_percentage :float
#  project_id      :integer
#  sale_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_units_on_id_and_project_id  (id,project_id)
#  index_units_on_id_and_sale_id     (id,sale_id)
#
