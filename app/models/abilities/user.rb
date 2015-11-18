module Abilities
  class User
    include CanCan::Ability

    def initialize(user)
      can :read, :all
      can :dashboard, ::User
      can :update,    ::User, id: user.id
      
      if user.activated?
        can :manage, ::Actor,          user_id: user.id
        can :manage, ::ActorMicro,     user_id: user.id
        can :manage, ::ActorMeso,      user_id: user.id
        can :manage, ::ActorMacro,     user_id: user.id
        can :manage, ::ActorRelation,  user_id: user.id
        can :manage, ::Action,         user_id: user.id
        can :manage, ::ActionMicro,    user_id: user.id
        can :manage, ::ActionMeso,     user_id: user.id
        can :manage, ::ActionMacro,    user_id: user.id
        can :manage, ::ActionRelation, user_id: user.id
        can :manage, ::Localization,   user_id: user.id
      end

      cannot [:activate, :deactivate], ::Localization
    end
  end
end