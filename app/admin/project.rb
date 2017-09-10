ActiveAdmin.register Project do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

	menu parent: 'Project', label: 'List'

	index do
		column :id
		column :name
		1.times do
			max_comm = projects.map(&:commissions).map(&:length).max
			(1..max_comm).each do |x|
				column "Commission #{x} (Effective Date)" do |project|
					comm = project.commissions[x-1]
					if comm
						"#{comm.percentage}% (#{comm.effective_date})"
					else
						'-'
					end
				end
			end
		end
		actions
	end

end

# == Schema Information
#
# Table name: projects
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
