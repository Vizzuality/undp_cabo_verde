module Abilities
  class User
    include CanCan::Ability

    def initialize(user)
      can :read,      ::User, id: user.id
      can :dashboard, ::User
      can :update,    ::User, id: user.id

      if user.activated?
        can :manage,                  ::Comment, user_id: user.id
        can [:activate, :deactivate], ::Comment, user_id: user.id
      end
    end
  end
end