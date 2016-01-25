class ActorLocalizationSerializer < BaseSerializer
  cached
  self.version = 7

  def attributes
    data = super
    data = include_locations
    data['start_date'] = object.start_date.to_date.iso8601 if object.start_date
    data['end_date']   = object.end_date.to_date.iso8601   if object.end_date
    data
  end

  def include_locations
    LocalizationArraySerializer.new(object.localization, root: false).serializable_hash
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
