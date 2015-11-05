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
      can :manage, ::ActorMicroMeso
      can :manage, ::ActorMicroMacro
      can :manage, ::ActorMesoMacro
      can :manage, ::Localization
      can [:activate, :deactivate], ::Localization

      cannot :make_user,               ::User, id: user.id
      cannot [:activate, :deactivate], ::User, id: user.id
    end
  end
end
