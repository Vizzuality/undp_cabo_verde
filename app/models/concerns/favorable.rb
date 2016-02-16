module Favorable
  extend ActiveSupport::Concern

  included do
    def is_favourite?(current_user)
      current_user.favourites.find_by(favorable_id: self.id, favorable_type: self.class.name).present? if current_user.present?
    end

    def favourite(current_user)
    	current_user.favourites.find_by(favorable_id: self.id, favorable_type: self.class.name) if current_user.present?
    end

    def favourite(current_user)
    	current_user.favourites.find_by(favorable_id: self.id, favorable_type: self.class.name) if current_user.present?
    end

    def favourite_id(current_user)
    	current_user.favourites.find_by(favorable_id: self.id, favorable_type: self.class.name).id if current_user.present?
    end
  end

  class_methods do
  end
end

