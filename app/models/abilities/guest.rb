module Abilities
  class Guest
    include CanCan::Ability

    def initialize(*)
      can :read, :all
      cannot :read, ::RelationType
    end
  end
end
