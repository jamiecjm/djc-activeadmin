ActiveAdmin.register Salevalue do
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

	menu parent: 'Sale'

	index title: 'Individual Sales' do
	    selectable_column
	    column :sale_id
	    column :date, sortable: 'sales.date' do |sv|
	    	sv.sale.date
	    end
	    column :status, sortable: 'sales.status' do |sv|
	    	sv.sale.status
	    end
	    column :project, sortable: 'projects.name' do |sv|
	    	sv.project.name
	    end
	    column 'Unit No.', sortable: 'units.unit_no' do |sv|
	    	sv.unit.unit_no
	    end
	    column :buyer, sortable: 'sales.buyer' do |sv|
	    	sv.sale.buyer
	    end
	    column 'REN SalePercentage (%)', sortable: :percentage do |sv|
	    	sv.percentage
	    end
	    column 'REN SPA Value (RM)', sortable: :spa do |sv|
	    	sv.spa
	    end
	    column 'REN Nett Value (RM)', sortable: :nett_value do |sv|
	    	sv.nett_value
	    end
	    column 'REN Commission (RM)', sortable: :comm do |sv|
	    	sv.comm
	    end
	    column 'Unit Size (sqft)', sortable: 'units.size' do |sv|
	    	sv.unit.size
	    end
	    column 'Unit SPA Value (RM)', sortable: 'units.spa_price' do |sv|
	    	sv.unit.spa_price
	    end
	    column 'Unit Nett Value (RM)', sortable: 'units.nett_price' do |sv|
	    	sv.unit.nett_price
	    end
	    actions
	end

	controller do
		def scoped_collection
			if params['q'] == nil
	        	super.where(:user_id => current_user.id).includes(:project,:unit)
	        else
	        	super.includes(:project,:unit)
	        end
		    # prevents N+1 queries to your database
		end

	end

end

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
#
# Indexes
#
#  index_salevalues_on_sale_id  (sale_id)
#  index_salevalues_on_user_id  (user_id)
#
