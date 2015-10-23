module Abilities
  class AdminUser
    include CanCan::Ability

    def initialize(user)
      can :read, :all
      can :manage, ::User

      cannot :make_user,               ::User, id: user.id
      cannot [:activate, :deactivate], ::User, id: user.id
    end
  end
end
