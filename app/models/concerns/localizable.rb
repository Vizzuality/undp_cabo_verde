module Localizable
  extend ActiveSupport::Concern

  included do
    has_many :localizations, as: :localizable, dependent: :destroy

    accepts_nested_attributes_for :localizations, allow_destroy: true

    after_create  :set_main_location, if: 'localizations.any?'
    after_update  :set_main_location, if: 'localizations.any?'

    scope :with_locations,  -> { joins(:localizations)                    }
    # Used in serach
    scope :only_meso_and_macro_locations, -> { where(type: ['ActorMeso', 'ActorMacro']).joins(:localizations) }
    scope :only_micro_locations,          -> { where(type: 'ActorMicro').joins(:location)                     }

    def main_location
      main_locations.first if main_locations.any?
    end

    def locations?
      localizations.any?
    end

    def main_locations
      localizations.main_locations
    end

    def main_street
      main_location.try(:street)
    end

    def main_zipcode
      main_location.try(:zip_code)
    end

    def main_country
      country_code = main_location.try(:country)

      country = ISO3166::Country[country_code]
      country.translations[I18n.locale.to_s] || country.name if country
    end

    def main_city
      main_location.try(:city)
    end

    def main_web
      main_location.try(:web_url)
    end

    def main_state
      main_location.try(:state)
    end

    def main_district
      main_location.try(:district)
    end

    def main_lat
      main_location.try(:lat)
    end

    def main_long
      main_location.try(:long)
    end

    def main_location_name
      main_location.try(:name)
    end

    def main_location_id
      main_location.try(:id)
    end

    def main_url
      main_location.try(:web_url)
    end

    def main_address
      [main_street, main_city, main_country].compact.join(', ')
    end

    protected

      def set_main_location
        if localizations.main_locations.empty?
          localizations.order(:created_at).first.update( main: true )
        end
      end
  end

  class_methods do
  end
end

