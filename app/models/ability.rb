class Ability
  include CanCan::Ability

  def initialize(user)
    user || User.new
    can :read, ActiveAdmin::Page, name: "Dashboard"
    can :create, Sale
    can :read, Salevalue, user_id: user
    can [:create,:update,:delete], Salevalue
    can [:read,:update], user
    if user.admin?
      can :manage, :all
    elsif user.leader?
      can :manage, User, team_id: user.team.subtree.pluck(:id)
      can :manage, Sale, teams: {id: user.team.subtree.pluck(:id)}
      can :manage, Project
    else
      can :read, User, id: user.subtree.pluck(:id)
      can :manage, Sale, users: {id: user.subtree.pluck(:id)}
    end
  end
end
