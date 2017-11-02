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

  permit_params :name, commissions_attributes: [:effective_date, :percentage]

	index do
		column :id
		column :name
		list_column 'Commissions (Date: Percentage(%))' do |p|
			p.commissions.pluck(:effective_date,:percentage).to_h
		end
		actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.has_many :commissions do |c|
        c.input :effective_date
        c.input :percentage
      end
    end
    actions
  end

  filter :name, label: 'Project Name'

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
