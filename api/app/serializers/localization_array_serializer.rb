class LocalizationArraySerializer < BaseSerializer
  cached
  self.version = 10

  attributes :id, :lat, :long, :main

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
