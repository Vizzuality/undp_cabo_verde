module Activable

  extend ActiveSupport::Concern

  included do
    before_save :set_deactivated_at

    scope :filter_actives,   -> { where(active: true)  }
    scope :filter_inactives, -> { where(active: false) }

    def activate
      update active: true
    end

    def deactivate
      update active: false
    end

    def deactivated?
      !self.active?
    end

    def activated?
      self.active?
    end
    
    def set_deactivated_at
      self.deactivated_at = Time.now if self.active_changed? && self.deactivated?
    end

    def status
      self.active? ? 'activated' : 'deactivated'
    end

    # ToDo deactivate activate dependencies
  end

  class_methods do
  end
  
end
