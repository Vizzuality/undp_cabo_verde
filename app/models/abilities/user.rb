module Abilities
  class User
    include CanCan::Ability

    def initialize(user)
      can :read,      ::User, id: user.id
      can :dashboard, ::User
      can :update,    ::User, id: user.id

      if user.activated?
        can :manage,                  ::Favourite, user_id: user.id
        can :manage,                  ::Comment,   user_id: user.id

        can [:create_favourite, :destroy_favourite], ::Actor
        can [:create_favourite, :destroy_favourite], ::ActorMicro
        can [:create_favourite, :destroy_favourite], ::ActorMeso
        can [:create_favourite, :destroy_favourite], ::ActorMacro

        can [:activate, :deactivate], ::Comment,   user_id: user.id
      end
    end
  end
end