class Ability
  include CanCan::Ability

  def initialize(user)
    if user # devise session users
      if user.admin?
        self.merge Abilities::AdminUser.new(user)
      elsif user.manager?
        self.merge Abilities::ManagerUser.new(user)
      else
        self.merge Abilities::User.new(user)
      end
    else
      self.merge Abilities::Guest.new(user)
    end
  end
end
