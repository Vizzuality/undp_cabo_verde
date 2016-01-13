class LocalizationArraySerializer < BaseSerializer
  cached
  self.version = 6

  attributes :id, :lat, :long

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
