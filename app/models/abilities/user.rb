module Abilities
  class User
    include CanCan::Ability

    def initialize(user)
      can :read, :all
      can :dashboard, ::User
      can :update,    ::User, id: user.id
    end
  end
end