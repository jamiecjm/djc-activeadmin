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
