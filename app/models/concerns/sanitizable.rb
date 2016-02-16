module Sanitizable
  extend ActiveSupport::Concern

  included do
    before_validation :sanitize_web,            if: "attributes.key?('web_url')"
    before_validation :sanitize_name,           if: "attributes.key?('name') and name.blank?"
    before_validation :sanitize_favorable_id,   if: "attributes.key?('favorable_id') and favorable_id.blank?"
    before_validation :sanitize_favorable_type, if: "attributes.key?('favorable_type') and favorable_type.blank?"
  end

  protected

    def sanitize_web
      unless self.web_url.blank? || self.web_url.start_with?('http://') || self.web_url.start_with?('https://')
        self.web_url = "http://#{self.web_url}"
      end
    end

    def sanitize_favorable_id
      if self.favorable_id.blank?
        self.favorable_id = self.id
      end
    end

    def sanitize_favorable_type
      if self.favorable_type.blank?
        self.favorable_type = 'Search'
      end
    end

    def sanitize_name
      if self.name.blank?
        self.name = 'Untitled'
      end
    end
end
