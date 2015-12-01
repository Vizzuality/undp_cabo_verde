class LocalizationSerializer < BaseSerializer
  cached
  self.version = 1

  attributes :name, :city, :lat, :long

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
