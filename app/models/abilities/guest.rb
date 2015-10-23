module Abilities
  class Guest
    include CanCan::Ability

    def initialize(user)
      can :read, :all
    end
  end
end
