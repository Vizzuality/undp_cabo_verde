module Abilities
  class AdminUser
    include CanCan::Ability

    def initialize(user)
      can :read, :all
      can :manage, ::User
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
      can :manage, ::Category
      can :manage, ::Comment
      can :manage, ::RelationType
      can :manage, ::Unit
      can :manage, ::Indicator
      can :manage, ::ActActorRelation
      can :manage, ::ActIndicatorRelation
      can :manage, ::Measurement
      can :manage, ::Favourite, user_id: user.id

      can [:activate, :deactivate], ::Localization
      can [:activate, :deactivate], ::Comment

      can [:create_favourite, :destroy_favourite], ::Actor
      can [:create_favourite, :destroy_favourite], ::ActorMicro
      can [:create_favourite, :destroy_favourite], ::ActorMeso
      can [:create_favourite, :destroy_favourite], ::ActorMacro

      cannot :make_user,               ::User, id: user.id
      cannot :make_manager,            ::User, id: user.id
      cannot [:activate, :deactivate], ::User, id: user.id
    end
  end
end
