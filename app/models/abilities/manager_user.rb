module Abilities
  class ManagerUser
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
        can :manage, ::Unit,          user_id: user.id
        can :manage, ::Indicator,            user_id: user.id
        can :manage, ::ActIndicatorRelation, user_id: user.id
        can :manage, ::Measurement,          user_id: user.id
        can :manage, ::ActActorRelation,     user_id: user.id
        can :manage, ::Favourite,            user_id: user.id

        can [:activate, :deactivate], ::Comment, user_id: user.id

        can [:create_favourite, :destroy_favourite], ::Actor
        can [:create_favourite, :destroy_favourite], ::ActorMicro
        can [:create_favourite, :destroy_favourite], ::ActorMeso
        can [:create_favourite, :destroy_favourite], ::ActorMacro

        can :create, ::OtherDomain
      end

      cannot :make_user,               ::User, id: user.id
      cannot [:activate, :deactivate], ::Localization
      cannot :read, ::RelationType
    end
  end
end