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

	scope :not_cancelled, default: true 

	scope :all

	before_action only: :index do
		if params['q']
			params['q']['date_gteq'] ||= ApplicationHelper.current_sales_cycle[:startdate]
			params['q']['date_lteq'] ||= ApplicationHelper.current_sales_cycle[:enddate]
		else
			params['q'] = {}
			params['q']['date_gteq'] ||= ApplicationHelper.current_sales_cycle[:startdate]
			params['q']['date_lteq'] ||= ApplicationHelper.current_sales_cycle[:enddate]
		end
	end

	skip_before_action :verify_authenticity_token, only: :email_report

	includes :project, :commission

	controller do
	  def apply_filtering(chain)
	      super(chain).distinct
	  end
	end

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
			f.semantic_errors *f.object.errors.keys
			
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

	filter :by_team, as: :select, label: 'View as',:collection => proc { User.order('prefered_name').map { |u| [u.prefered_name, "[#{u.id}]"] } }
	filter :date
	filter :status, as: :select, :collection => Sale.statuses
	filter :project, as: :select, :collection => proc{ Project.all.order('name') }
	filter :unit_no
	filter :buyer
	filter :users, label: 'REN', :collection => proc {User.order('prefered_name')}, as: :select, input_html: {multiple: true}
	filter :spa_price
	filter :nett_price
	filter :commission_percentage, as: :numeric
	filter :comm

	sidebar :summary, priority: 0, only: :index do
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
		status: %w[Done Booked cancelled]
	}, confirm: 'Choose Status' do |ids, inputs|
		Sale.find(ids).each do |sale|
	      sale.update(status: Sale.statuses[inputs['status']])
	    end

	    redirect_back fallback_location: collection_path, notice: "Sales have been maked as #{inputs['status']}"
	end

	member_action :email_report_popup do
		@id = resource.id
		respond_to do |format|
			format.js
		end
	end

	member_action :email_report, method: :post do
		redirect_back fallback_location: resource_path(params[:id]), notice: 'Email has been sent successfully'
	end

	action_item :email_report_popup, only: :show, class: 'email_report_popup' do
		link_to 'Email Report', email_report_popup_sale_path, remote: true
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
