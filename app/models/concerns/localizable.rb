module Localizable
  extend ActiveSupport::Concern

  included do
    def main_location
      main_locations.first.localization if main_locations.any?
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
      country.translations[I18n.locale.to_s] || country.name
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

    def main_url
      main_location.try(:web_url)
    end
  end

  class_methods do
  end
end

