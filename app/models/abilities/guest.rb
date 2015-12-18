module Abilities
  class Guest
    include CanCan::Ability

    def initialize(*)
      can :read, :all
      cannot :read, ::RelationType
      cannot :read, ::Unit
    end
  end
end
