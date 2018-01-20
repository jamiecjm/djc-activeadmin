class Ability
  include CanCan::Ability

  def initialize(user)
    user || User.new
    can :read, ActiveAdmin::Page, name: "Dashboard"
    can :read, ActiveAdmin::Page, name: "Monthly Sales Figure"
    can :read, ActiveAdmin::Page, name: "Team Sales Figure"
    can :create, Sale
    can [:create,:update,:delete], Salevalue
    can [:read, :update], user

    if user.new_record? || user.leader?
      can :create, User
    end

    if user.admin?
      can :manage, :all
    elsif user.leader?
      can :manage, User, team_id: user.team.subtree.pluck(:id)
      can :manage, Sale, teams: {id: user.team.subtree.pluck(:id)}
      can :read, Salevalue, team: {id: user.team.subtree.pluck(:id)}
      can :manage, Project
    else
      can [:read], User, id: user.subtree.pluck(:id)
      can :manage, Sale, users: {id: user.subtree.pluck(:id)}
      can :read, Salevalue, user_id: user.subtree.pluck(:id)
    end
  end
end
