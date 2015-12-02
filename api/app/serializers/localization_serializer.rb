class LocalizationSerializer < BaseSerializer
  cached
  self.version = 1

  attributes :name, :country, :city, :zip_code, :state, :district, :web_url, :lat, :long

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
