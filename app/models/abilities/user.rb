module Abilities
  class User
    include CanCan::Ability

    def initialize(user)
      can :read, :all
      can :dashboard, ::User
      can :update,    ::User, id: user.id
      
      if user.activated?
        can :manage, ::Actor,         user_id: user.id
        can :manage, ::ActorMicro,    user_id: user.id
        can :manage, ::ActorMeso,     user_id: user.id
        can :manage, ::ActorMacro,    user_id: user.id
        can :manage, ::ActorRelation, user_id: user.id
        can :manage, ::Act,           user_id: user.id
        can :manage, ::ActMicro,      user_id: user.id
        can :manage, ::ActMeso,       user_id: user.id
        can :manage, ::ActMacro,      user_id: user.id
        can :manage, ::ActRelation,   user_id: user.id
        can :manage, ::Localization,  user_id: user.id
        can :manage, ::Comment,       user_id: user.id
        
        can [:activate, :deactivate], ::Comment, user_id: user.id
      end

      cannot [:activate, :deactivate], ::Localization
      cannot :read, ::RelationType
    end
  end
end