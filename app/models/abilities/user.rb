module Abilities
  class User
    include CanCan::Ability

    def initialize(user)
      can :read, :all
      can :dashboard, ::User
      can :update, ::User, id: user.id

      if user.activated?
        can :manage, ::Comment,       user_id: user.id
        can [:activate, :deactivate], ::Comment, user_id: user.id
      end

      cannot :read, ::RelationType
    end
  end
end