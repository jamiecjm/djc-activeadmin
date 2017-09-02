# == Schema Information
#
# Table name: commissions
#
#  id             :integer          not null, primary key
#  project_id     :integer
#  percentage     :float
#  effective_date :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_commissions_on_id_and_project_id  (id,project_id)
#

class Commission < ApplicationRecord
	belongs_to :project, optional: true
	has_many :sales
end
