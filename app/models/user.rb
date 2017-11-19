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
#  leader?                :boolean          default(FALSE)
#
# Indexes
#
#  index_users_on_ancestry              (ancestry)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_prefered_name         (prefered_name)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_team_id               (team_id)
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :timeoutable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:login]
  
  attr_accessor :login

  scope :with_team, -> {where.not(team_id: nil).order('prefered_name')}
  scope :approved, -> {where(approved?: true).order('prefered_name')}
  scope :awaiting_approval, -> {where(approved?: false).order('prefered_name')}

  has_many :sales, :through => :salevalues
  has_many :salevalues, dependent: :destroy
  belongs_to :team, optional: true
  has_one :leader, through: :team

  has_ancestry :orphan_strategy => :rootify

  before_validation :titleize_name
  before_validation :set_team
  
  validates_confirmation_of :password
  validates :prefered_name, uniqueness: {message: "has been taken. Check with you leader whether you have an account."}
  validates :email, presence: true

  enum location: ["KL","JB","Penang","Melaka"]
  enum position: ["REN","Team Leader","Team Manager","admin"]

  # def leader
  #   self.team.leader
  # end

  def display_name
    prefered_name
  end

  def is_leader?
    if Team.find_by(leader_id: id)
      true
    else
      false
    end
  end

  def login=(login)
    @login = login
  end

  def login
    @login || self.prefered_name || self.email
  end

  def self.merge
    name_arrays = self.select(:prefered_name).group(:prefered_name).having("count(*) > 1").pluck(:prefered_name)
    name_arrays.each do |name|
      duplicates = self.where(prefered_name: name).order('id')
      duplicates[1].salevalues.update_all(user_id: duplicates[0].id)
      duplicates[1].destroy
    end
  end

  def team_members
    if leader?
      User.where(team_id: team.subtree)
    else
      User.where(id: subtree)
    end
  end

  def team_members_sales
    Sale.not_cancelled.joins(:users).where('users.id': team_members)
    # team_members.map(&:sales).map(&:not_cancelled)
  end

  private

  def titleize_name
    self.name = self.name.titleize.strip if self.name.present?
    self.prefered_name = self.prefered_name.titleize.strip if self.prefered_name.present?
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(prefered_name) = lower(:value) OR lower(email) = lower(:value)", { :value => login }]).first
    elsif conditions.has_key?(:prefered_name) || conditions.has_key?(:email)
      where(conditions.to_hash).first
    end
  end

  def email_required?
    !team_id.nil?
  end

  def set_team
    if self.parent.present? && !self.leader?
      self.team_id = self.parent.team_id 
    end
  end

  def recalculate
    self.total_spa = u.salevalues.not_cancelled.sum(:spa)
    self.total_nett_value = u.salevalues.not_cancelled.sum(:nett_value)
    self.total_comm = u.salevalues.not_cancelled.sum(:comm)
    self.total_sales = u.salevalues.not_cancelled.length
    self.save
  end


end
