class ActActorRelationSerializer < BaseSerializer
  cached
  self.version = 6

  attributes :actor_id, :act_id

  has_one :relation_type

  def attributes
    data = super
    data['start_date'] = object.start_date.to_date.iso8601 if object.start_date
    data['end_date']   = object.end_date.to_date.iso8601   if object.end_date
    data
  end

  def include_associations!
    include! :relation_type, serializer: RelationTypeSerializer
  end

  def cache_key
    # For filter options
    cache_params = nil
    
    self.class.cache_key << [object, object.updated_at, cache_params]
  end
end
