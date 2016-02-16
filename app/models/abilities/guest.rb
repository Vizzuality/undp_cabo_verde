module Abilities
  class Guest
    include CanCan::Ability

    def initialize(user)
    end
  end
end
