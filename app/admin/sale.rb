ActiveAdmin.register Sale do
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

	menu parent: 'Sale', label: 'Team'

	index title: 'Team Sales' do
		selectable_column
		column :id
		column :date
		column :status
		column 'Project', sortable: 'projects.name' do |sale|
			sale.project.name
		end
		column 'Unit No.', sortable: 'units.unit_no' do |sale|
			sale.unit.unit_no
		end
		column :buyer
		column 'Unit Size', sortable: 'units.size' do |sale|
			sale.unit.size
		end
		column 'SPA Value (RM)', sortable: 'units.spa_price' do |sale|
	    	sale.unit.spa_price
	    end
	    column 'Nett Value (RM)', sortable: 'units.nett_price' do |sale|
	    	sale.unit.nett_price
	    end
	    column 'Comm Percentage (%)', sortable: 'commissions.percentage' do |sale|
	    	sale.commission.percentage
	    end
	    column 'Commision (RM)', sortable: 'units.comm' do |sale|
	    	sale.unit.comm
	    end
	    actions
	end

	controller do
		def scoped_collection
			if params['q'] == nil
				if current_user.leader?
	        		super.includes(:project,:unit,:commission,:teams,:users).where('teams.id': current_user.team.subtree.pluck(:id))
	        	else
	        		super.includes(:project,:unit,:commission,:teams,:users).where('users.id': current_user.subtree.pluck(:id))
	        	end
	        else
	        	super.includes(:project,:unit,:commission,:teams,:users)
	        end
		    # prevents N+1 queries to your database
		end

	end

end

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
