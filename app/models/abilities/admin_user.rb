module Abilities
  class AdminUser
    include CanCan::Ability

    def initialize(user)
      can :read, :all
      can :manage, ::User
      can :manage, ::Actor
      can :manage, ::Person
      can :manage, ::Organization

      cannot :make_user,               ::User, id: user.id
      cannot [:activate, :deactivate], ::User, id: user.id
    end
  end
end
