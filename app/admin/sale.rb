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
							:package, :remark, salevalues_attributes: [:user_id, :percentage, :comm, :nett_value, :spa],
							salevalues2_attributes: [:other_user, :percentage, :comm, :nett_value, :spa]

controller do
	def scoped_collection
		scoped = super.includes(:project,:unit,:commission,:teams,:users, :salevalues2, salevalues: :user)
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
		input :date
		f.has_many :salevalues, heading: 'REN' do |sv|
			sv.input :user_id, :label => 'Name', :as => :select, :collection => User.with_team.order('prefered_name').map{|u| [u.prefered_name, u.id]}
			sv.input :percentage
		end
		f.has_many :salevalues2, heading: 'Other REN' do |sv|
			sv.input :other_user, label: 'Name'
			sv.input :percentage
		end
		input :project
		input :unit_no
		input :size, label: 'Unit size (sqft)', min: 0, step: 'any'
		input :spa_price, label: 'SPA value (RM)', min: 0, step: 'any'
		input :nett_price, label: 'Nett value (RM)', min: 0, step: 'any'
		input :buyer
		input :package
		input :remark
	end

	if !f.object.new_record?
		f.inputs 'SPA and LA Sign Date' do
			input :spa_sign_date
			input :la_date
		end
	end

	
	actions
end

filter :date
filter :users, label: 'REN', :collection => proc {current_user.team_members.order('prefered_name').map{|u| [u.prefered_name, u.id]}}
filter :project, :collection => Project.all.order('name')
filter :unit_no

sidebar :summary, priority: 0, only: :index do
	columns do
		column do
			span 'Total SPA Value'
		end
		column do
			span number_to_currency(sales.TotalSPA, unit: 'RM ', delimeter: ',')
		end
	end
	columns do
		column do
			span 'Total Nett Value'
		end
		column do
			span number_to_currency(sales.TotalNetValue, unit: 'RM ', delimeter: ',')
		end
	end
	columns do
		column do
			span 'Total Commision'
		end
		column do
			span number_to_currency(sales.TotalComm, unit: 'RM ', delimeter: ',')
		end
	end	
	columns do
		column do
			span 'Total Sales'
		end
		column do
			span sales.TotalSales
		end
	end
end

end

# == Schema Information
#
# Table name: sales
#
#  id              :integer          not null, primary key
#  date            :date
#  buyer           :string
#  project_id      :integer
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
#  nett_price      :float
#  spa_price       :float
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
