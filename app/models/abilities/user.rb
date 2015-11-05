module Abilities
  class User
    include CanCan::Ability

    def initialize(user)
      can :read, :all
      can :dashboard, ::User
      can :update,    ::User, id: user.id

      can :manage, ::Actor,      user_id: user.id if user.activated?
      can :manage, ::ActorMicro, user_id: user.id if user.activated?
      can :manage, ::ActorMeso,  user_id: user.id if user.activated?
      can :manage, ::ActorMacro, user_id: user.id if user.activated?
      can :manage, ::ActorMicroMeso,  user_id: user.id if user.activated?
      can :manage, ::ActorMicroMacro, user_id: user.id if user.activated?
      can :manage, ::ActorMesoMacro,  user_id: user.id if user.activated?
      can :manage, ::Localization,    user_id: user.id if user.activated?

      cannot [:activate, :deactivate], ::Localization
    end
  end
end