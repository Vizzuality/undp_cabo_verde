class ActorSerializer < BaseSerializer
  cached
  self.version = 1

  attributes :id, :name, :level

  has_many :localizations, key: :locations, serializer: LocalizationSerializer

  def level
    object.type
  end

  def cache_key
    # For filter options
    cache_params = nil
    
    self.class.cache_key << [object, object.updated_at, localizations, cache_params]
  end
end
