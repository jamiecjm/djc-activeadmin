ActiveAdmin.register User do

  menu parent: 'Team', label: 'Members'

  permit_params :email, :password, :password_confirmation, :name, :prefered_name, :phone_no, :birthday, :parent_id,
                :location

  scope :approved, default: true

  scope :awaiting_approval, if: proc {current_user.leader?} 

  scope :sales do |users|
    users.joins(:sales).where('sales.status != ?', 2).group('users.id').select('SUM(salevalues.nett_value) as total_nett_value', User.attribute_names)
  end 

  before_action only: :index do
    if params['scope'] == 'sales'
      params['order'] = 'total_nett_value_desc'

      if params['q']
        params['q']['sales_date_gteq_datetime'] ||= ApplicationHelper.first_day_of_month(Date.today)
        params['q']['sales_date_lteq_datetime'] ||= Date.today
      else
        params['q'] = {}
        params['q']['sales_date_gteq_datetime'] ||= ApplicationHelper.first_day_of_month(Date.today)
        params['q']['sales_date_lteq_datetime'] ||= Date.today
      end

    else
      if params['order'] == 'total_nett_value_desc'
        params['order'] = 'id_desc'
      end

      if params['q']
        params['q']['sales_date_gteq_datetime'] = nil
        params['q']['sales_date_lteq_datetime'] = nil
      end

    end

  end  

  index title: 'Members' do
    if params['scope'] != 'sales'
      selectable_column
      id_column
      column :prefered_name
      column 'Full Name', :name
      column 'Referrer' do |user|
        user.parent&.prefered_name
      end
      column 'Leader' do |user|
        user.team.leader.prefered_name
      end
      column :location
      column :phone_no
      column :email
      column :birthday
      column :created_at
      actions
    else
      id_column
      column :prefered_name, sortable: nil
      column 'Referrer' do |user|
        user.parent&.prefered_name
      end
      column 'Leader' do |user|
        user.team.leader.prefered_name
      end
      column :location, sortable: nil
      column 'Total SPA (RM)' do |user|
        number_to_currency(user.salevalues.not_cancelled.where("date >= ?", params['q']['sales_date_gteq_datetime']).where("date <= ?", params['q']['sales_date_lteq_datetime']).TotalSPA, unit: '')
      end
      column 'Total Nett Value (RM)' do |user|
        number_to_currency(user.salevalues.not_cancelled.where("date >= ?", params['q']['sales_date_gteq_datetime']).where("date <= ?", params['q']['sales_date_lteq_datetime']).TotalNetValue, unit: '')
      end
      column 'Total Comm (RM)' do |user|
        number_to_currency(user.salevalues.not_cancelled.where("date >= ?", params['q']['sales_date_gteq_datetime']).where("date <= ?", params['q']['sales_date_lteq_datetime']).TotalComm, unit: '')
      end
      column 'Total Sales' do |user|
        user.salevalues.not_cancelled.length
      end
    end
  end

  filter :sales_date, as: :date_range, if: proc { params['scope'] == 'sales' }

  filter :name, label: 'Full Name', as: :select
  filter :prefered_name, as: :select
  filter :leader, collection: proc{ User.where(leader?: true) }
  filter :location, as: :select
  
  filter :phone_no, unless: proc { params['scope'] == 'sales' }
  filter :email, unless: proc { params['scope'] == 'sales' }
  filter :birthday, unless: proc { params['scope'] == 'sales' }
  filter :created_at, unless: proc { params['scope'] == 'sales' }


  form do |f|
    f.inputs do
      f.semantic_errors *f.object.errors.keys
      f.input :name
      f.input :prefered_name
      f.input :phone_no
      f.input :email
      f.input :birthday
      f.input :parent_id
      f.input :location
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  batch_action :approve, confirm: 'Approve the selected REN?' do |ids|
    User.where(id: ids).update_all(approved?: true)
    redirect_back fallback_location: collection_path, notice: 'Selected RENs have been approved.'
  end

  batch_action :unapprove, confirm: 'Approve the selected REN?' do |ids|
    User.where(id: ids).update_all(approved?: false)
    redirect_back fallback_location: collection_path, alert: 'Selected RENs have been unapproved.'
  end 


end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string
#  encrypted_password     :string
#  name                   :string
#  prefered_name          :string           not null
#  phone_no               :string
#  birthday               :date
#  team_id                :integer
#  location               :integer
#  position               :integer
#  approved?              :boolean          default(FALSE)
#  ancestry               :string
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  admin                  :boolean          default(FALSE)
#
# Indexes
#
#  index_users_on_ancestry              (ancestry)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_prefered_name         (prefered_name)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_team_id               (team_id)
#
