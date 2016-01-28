class LocalizationSerializer < BaseSerializer
  cached
  self.version = 10

  attributes :id, :name, :iso, :country, :city, :zip_code, :state,
             :district, :street, :web_url, :lat, :long, :main

  def iso
    object.country
  end

  def country
    country_iso = ISO3166::Country[object.country]
    country_iso.translations[I18n.locale.to_s] || object.country_iso.name if country_iso
  end

  def attributes
    data = super
    data['start_date'] = object.start_date.to_date.iso8601 if object.start_date
    data['end_date']   = object.end_date.to_date.iso8601   if object.end_date
    data
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
