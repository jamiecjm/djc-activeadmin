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

	permit_params :date, :project_id, :unit_no, :unit_size, :spa_price, :nett_price, :buyer, :size, :spa_sign_date, :la_date,
								:package, :remark, salevalues_attributes: [:id, :user_id, :percentage, :comm, :nett_value, :spa, :_destroy],
								salevalues2_attributes: [:id, :other_user, :percentage, :comm, :nett_value, :spa, :_destroy]

	scope :not_canceled, default: true do |sales|
		if params['q']
			from = params["q"]['date_gteq']
			to = params['q']['date_lteq']
		end
		
		from ||= ApplicationHelper.current_sales_cycle[:startdate]
		to ||= Date.today
		sales.not_canceled.where('date >= ?', from).where('date <= ?', to)
	end

	scope :all

	includes :project, :commission, :salevalues2, :users

	index title: 'Team Sales' do
		selectable_column
		column :id
		column :date
		column :status
		column 'Project', sortable: 'projects.name' do |sale|
			sale.project.name
		end
		column 'Unit No.', :unit_no
		column :buyer
		1.times do
			max_ren = (sales.map(&:salevalues).map(&:length)+sales.map(&:salevalues2).map(&:length)).max
			(1..max_ren).each do |x|
				column "REN #{x} (%)", sortable: 'users.name' do |sale|
					sv = sale.salevalues
					if sv[x-1]
						"#{sv[x-1].user.prefered_name} (#{sv[x-1].percentage}%)"
					elsif sv2 = sale.salevalues2[x-sv.length-1]
						"#{sv2.other_user} (#{sv2.percentage}%)"
					else
						'-'
					end
				end
			end
		end
		column 'Unit Size', sortable: :size do |sale|
			number_with_delimiter(sale.size)
		end
		column 'SPA Value (RM)', sortable: :spa_price do |sale|
			number_with_delimiter('%.2f' % sale.spa_price)
		end
		column 'Nett Value (RM)', sortable: :nett_price do |sale|
			number_with_delimiter('%.2f' % sale.nett_price)
		end
		column 'Comm Percentage (%)', sortable: 'commissions.percentage' do |sale|
			('%.2f' % sale.commission.percentage)
		end
		column 'Commision (RM)', sortable: :comm do |sale|
			number_with_delimiter('%.2f' % sale.comm)
		end
		actions
	end

	form do |f|
		f.inputs do
			
			input :date
			f.has_many :salevalues, heading: 'REN', :allow_destroy => true, :new_record => 'Add REN' do |sv|
				sv.input :user_id, :label => 'Name', :as => :select, :collection => User.with_team.order('prefered_name').map{|u| [u.prefered_name, u.id]}
				sv.input :percentage
			end
			f.has_many :salevalues2, heading: 'Other REN', :allow_destroy => true, :new_record => 'Add Other REN' do |sv|
				sv.input :other_user, label: 'Name'
				sv.input :percentage
			end
			input :project
			input :unit_no
			input :size, label: 'Unit size (sqft)', min: 0, step: 'any'
			input :spa_price, label: 'SPA value (RM)', min: 0, step: 'any'
			input :nett_price, label: 'Nett value (RM)', min: 0, step: 'any'
			input :buyer
			if !f.object.new_record?
				input :status
			end
			input :package
			input :remark
		end

		if !f.object.new_record?
			f.inputs 'SPA and LA Sign Date' do
				input :spa_sign_date, label: 'SPA Sign Date'
				input :la_date, label: 'LA Sign Date'
			end
		end

		
		actions
	end

	show do

		attributes_table do
			row :date
			list_row :ren do |s|
				s.salevalues.map {|sv| sv.user.prefered_name + " (#{sv.percentage}%)"}
			end
			list_row :other_ren do |s|
				s.salevalues2.map {|sv| sv.other_user + " (#{sv.percentage}%)"}
			end
			row :project
			row :unit_no
			row :size
			row :spa_value do |s|
				number_to_currency(s.spa_price, unit: 'RM ', precision: 2 )
			end
			row :nett_value do |s|
				number_to_currency(s.nett_price, unit: 'RM ', precision: 2 )
			end
			row :buyer
			row :status
			row :package
			row :remark
		end

		attributes_table title: 'SPA and LA Sign Date' do
			
			row :spa_sign_date, label: 'SPA Sign Date'
			row :la_date, label: 'LA Sign Date'
			
		end

	end


	filter :date
	filter :users, label: 'REN', :collection => proc {User.order('prefered_name').map{|u| [u.prefered_name, u.id]}}, as: :select, input_html: {multiple: true}
	filter :project, :collection => Project.all.order('name'), as: :select
	filter :unit_no

	sidebar :summary, priority: 0, only: :index do
		columns do
			column do
				span 'Start Date'
			end
			column do
				if params['q']
					from = params["q"]['date_gteq']
				end
				
				from ||= ApplicationHelper.current_sales_cycle[:startdate]
			
				span from
			end
		end
		columns do
			column do
				span 'End Date'
			end
			column do
				if params['q']
					to = params["q"]['date_lteq']
				end
				
				to ||= Date.today
			
				span to
			end
		end
		columns do
			column do
				span 'Total SPA Value'
			end
			column do
				span number_to_currency(sales.per(sales.length * sales.total_pages).TotalSPA, unit: 'RM ', delimeter: ',')
			end
		end
		columns do
			column do
				span 'Total Nett Value'
			end
			column do
				span number_to_currency(sales.per(sales.length * sales.total_pages).TotalNetValue, unit: 'RM ', delimeter: ',')
			end
		end
		columns do
			column do
				span 'Total Commision'
			end
			column do
				span number_to_currency(sales.per(sales.length * sales.total_pages).TotalComm, unit: 'RM ', delimeter: ',')
			end
		end	
		columns do
			column do
				span 'Total Sales'
			end
			column do
				span sales.per(sales.length * sales.total_pages).length
			end
		end
	end

	batch_action :destroy, false

	batch_action :change_status_of, form: {
		status: %w[Done Booked Canceled]
	}, confirm: 'Choose Status' do |ids, inputs|
		batch_action_collection.find(ids).each do |sale|
	      sale.update(status: Sale.statuses[inputs['status']])
	    end

	    redirect_back fallback_location: collection_path, notice: "Sales have been maked as #{inputs['status']}"
	end

end

# == Schema Information
#
# Table name: sales
#
#  id              :integer          not null, primary key
#  date            :date             not null
#  buyer           :string
#  project_id      :integer          not null
#  unit_id         :integer
#  status          :integer          default("Booked")
#  package         :string
#  remark          :string
#  spa_sign_date   :date
#  la_date         :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  commission_id   :integer
#  unit_no         :string
#  size            :integer
#  nett_price      :integer          not null
#  spa_price       :integer          not null
#  comm            :float
#  comm_percentage :float
#
# Indexes
#
#  index_sales_on_commission_id  (commission_id)
#  index_sales_on_date           (date)
#  index_sales_on_project_id     (project_id)
#  index_sales_on_unit_id        (unit_id)
#
