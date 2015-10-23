module Roleable

  extend ActiveSupport::Concern

  included do

    scope :admin_users, -> { joins(:admin_users) }

    def make_admin
      self.create_admin_user
    end

    def make_user
      self.admin_user.destroy
    end

    def admin?
      admin_user.present?
    end
    
  end

  class_methods do
  end
  
end
