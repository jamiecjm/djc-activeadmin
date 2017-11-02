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

	menu parent: 'Sale', label: 'Individual'

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
	    column 'Unit No.', sortable: 'sales.unit_no' do |sv|
	    	sv.sale.unit_no
	    end
	    column :buyer, sortable: 'sales.buyer' do |sv|
	    	sv.sale.buyer
	    end
	    column 'REN SalePercentage (%)',sortable: :percentage do |sv|
	    	number_with_delimiter('%.2f' % sv.percentage)
	    end
	    column 'REN SPA Value (RM)',sortable: :spa do |sv|
	    	number_with_delimiter('%.2f' % sv.spa)
		end	
	    column 'REN Nett Value (RM)', sortable: :nett_value do |sv|
	    	number_with_delimiter('%.2f' % sv.nett_value)
	    end
	    column 'REN Commission (RM)', sortable: :comm do |sv|
	    	number_with_delimiter('%.2f' % sv.comm)
	    end
	    column 'Unit Size (sqft)', sortable: 'sales.size' do |sv|
	    	sv.sale.size
	    end
	    column 'Unit SPA Value (RM)', sortable: 'saless.spa_price' do |sv|
	    	number_with_delimiter('%.2f' % sv.sale.spa_price)
	    end
	    column 'Unit Nett Value (RM)', sortable: 'sales.nett_price' do |sv|
	    	number_with_delimiter('%.2f' % sv.sale.nett_price)
	    end
	end

	controller do
		def scoped_collection
			super.includes(:project,:unit)
		end

	end

	sidebar :summary, priority: 0, only: :index do

		columns do
			column do
				span 'Total SPA Value'
			end
			column do
				span number_to_currency(salevalues.pluck(:spa).inject(:+), unit: 'RM ', delimeter: ',')
			end
		end
		columns do
			column do
				span 'Total Nett Value'
			end
			column do
				span number_to_currency(salevalues.pluck(:nett_value).inject(:+), unit: 'RM ', delimeter: ',')
			end
		end
		columns do
			column do
				span 'Total Commision'
			end
			column do
				span number_to_currency(salevalues.pluck(:comm).inject(:+), unit: 'RM ', delimeter: ',')
			end
		end	
		columns do
			column do
				span 'Total Sales'
			end
			column do
				span salevalues.length
			end
		end
	end

	filter :user, label: 'REN', :collection => proc {current_user.team_members.order('prefered_name').map{|u| [u.prefered_name, u.id]}}
	filter :project, :collection => Project.all.order('name')

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
#  other_user :string
#
# Indexes
#
#  index_salevalues_on_sale_id  (sale_id)
#  index_salevalues_on_user_id  (user_id)
#
