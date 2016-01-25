class LocalizationSerializer < BaseSerializer
  cached
  self.version = 7

  attributes :name, :iso, :country, :city, :zip_code, :state, :district, :street, :web_url, :lat, :long

  def iso
    object.country
  end

  def country
    country_iso = ISO3166::Country[object.country]
    country_iso.translations[I18n.locale.to_s] || object.country_iso.name if country_iso
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
