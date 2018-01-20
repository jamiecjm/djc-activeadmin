# == Schema Information
#
# Table name: teams
#
#  id         :integer          not null, primary key
#  name       :string
#  leader_id  :integer
#  ancestry   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_teams_on_ancestry   (ancestry)
#  index_teams_on_leader_id  (leader_id)
#

class Team < ApplicationRecord

	has_many :users
	belongs_to :leader, optional: true, :class_name => "User"
  has_many :sales, through: :users
	has_ancestry
	validates :leader_id, uniqueness: :true

  def display_name
    leader.prefered_name
  end

  def sub_tree_sales
    Sale.joins(:users).where("users.team_id" => self.subtree).distinct
  end

  def sub_tree_salevalues
    Salevalue.joins(:user).where("users.team_id" => self.subtree)
  end

  def sub_tree_members
    User.where(team_id: self.subtree.pluck(:id))
  end
end
