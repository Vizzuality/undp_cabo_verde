module Roleable
  extend ActiveSupport::Concern

  included do
    # User types
    has_one :admin_user,   dependent: :destroy
    has_one :manager_user, dependent: :destroy

    scope :admin_users,       -> { joins(:admin_users)                         }
    scope :manager_users,     -> { joins(:manager_users)                       }
    scope :not_admin_users,   -> { where.not(id: AdminUser.select(:user_id))   }
    scope :not_manager_users, -> { where.not(id: ManagerUser.select(:user_id)) }

    def make_admin
      make_user && self.create_admin_user
    end

    def make_manager
      make_user && self.create_manager_user
    end

    def make_user
      user_roles = [self.admin_user, self.manager_user].compact
      user_roles.each do |role|
        role.destroy
      end
    end

    def admin?
      admin_user.present?
    end

    def manager?
      manager_user.present?
    end

    def user?
      admin_user.blank? && manager_user.blank?
    end

    def role_name
      if admin?
        I18n.t('shared.admin')
      elsif manager?
        I18n.t('shared.manager')
      else
        I18n.t('shared.user')
      end
    end

  end

  class_methods do
  end
end
