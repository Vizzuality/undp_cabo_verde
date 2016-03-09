module Abilities
  class ManagerUser
    include CanCan::Ability

    def initialize(user)
      can :read, :all
      can :dashboard, ::User
      can :update,    ::User, id: user.id

      if user.activated?
        can :manage, ::Actor
        can :manage, ::ActorMicro
        can :manage, ::ActorMeso
        can :manage, ::ActorMacro
        can :manage, ::ActorRelation
        can :manage, ::Act
        can :manage, ::ActMicro
        can :manage, ::ActMeso
        can :manage, ::ActMacro
        can :manage, ::ActRelation
        can :manage, ::Localization
        can :manage, ::Comment, user_id: user.id
        can :manage, ::Unit
        can :manage, ::Indicator
        can :manage, ::ActIndicatorRelation
        can :manage, ::Measurement
        can :manage, ::ActActorRelation
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
