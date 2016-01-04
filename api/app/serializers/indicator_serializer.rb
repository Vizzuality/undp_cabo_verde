class IndicatorSerializer < BaseSerializer
  cached
  self.version = 5

  attributes :id, :name, :alternative_name

  # Locations
  has_many :indicator_localizations, key: :locations

  def include_associations!
    include! :indicator_localizations, serializer: RelationalLocalizationSerializer
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
