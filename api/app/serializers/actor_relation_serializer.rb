class ActorRelationSerializer < BaseSerializer
  cached
  self.version = 110

  attributes :parent_id, :child_id, :start_date, :end_date

  has_one :relation_type

  def cache_key
    # For filter options
    cache_params = nil
    
    self.class.cache_key << [object, object.updated_at, cache_params]
  end

  def include_associations!
    include! :relation_type, serializer: RelationTypeSerializer
  end
end
