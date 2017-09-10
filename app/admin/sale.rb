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

	controller do
		def scoped_collection
			if params['q'] == nil
				if current_user.leader?
	        		super.includes(:users, :project,:commission,:teams,salevalues: :user).where('teams.id': current_user.team.subtree.pluck(:id))
	        	else
	        		super.includes(:users, :project,:commission,:teams,salevalues: :user).where('users.id': current_user.subtree.pluck(:id))
	        	end
	        else
	        	super.includes(:project,:unit,:commission,:teams,:users, salevalues: :user)
	        end
		    # prevents N+1 queries to your database
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
			max_ren = sales.map(&:users).map(&:length).max
			(1..max_ren).each do |x|
				column "REN #{x} (%)", sortable: 'users.name' do |sale|
					sv = sale.salevalues[x-1]
					if sv
						"#{sv.user.prefered_name} (#{sv.percentage}%)"
					else
						'-'
					end
				end
			end
		end
		column 'Unit Size', :size
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
				sv.input :user, label: 'Name'
				sv.input :percentage
			end
			f.has_many :salevalues2, heading: 'Other REN' do |sv|
				sv.input :user, label: 'Name'
				sv.input :percentage
			end
			input :project
			input :unit_no
			input :size, label: 'Unit size (sqft)'
			input :spa_price, label: 'SPA value (RM)'
			input :nett_price, label: 'Nett value (RM)' 
			input :buyer
			input :package
			input :remark
		end
		actions
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
