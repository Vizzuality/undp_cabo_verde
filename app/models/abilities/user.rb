module Abilities
  class User
    include CanCan::Ability

    def initialize(user)
      can :read, :all
      can :dashboard, ::User
      can :update,    ::User, id: user.id

      can :manage, ::Actor,        user_id: user.id
      can :manage, ::Person,       user_id: user.id
      can :manage, ::Organization, user_id: user.id
    end
  end
end