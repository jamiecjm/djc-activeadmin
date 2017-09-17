ActiveAdmin.register User do

  menu parent: 'Team', label: 'Members'

  permit_params :email, :password, :password_confirmation, :name, :prefered_name, :phone_no, :birthday, :parent_id,
                :location

  index title: 'Members' do
    selectable_column
    id_column
    column 'Full Name', :name
    column :prefered_name
    column 'Referrer' do |user|
      user.parent.prefered_name
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
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
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
