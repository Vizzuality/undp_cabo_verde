module Abilities
  class Guest
    include CanCan::Ability

    def initialize(*)
      can :read, :all
    end
  end
end
