class RelationInfoSerializer < BaseSerializer
  cached
  self.version = 9

  def attributes
    data = super
    data['start_date']    = object.start_date.to_date.iso8601  if object.start_date.present?
    data['end_date']      = object.end_date.to_date.iso8601    if object.end_date.present?
    data['title']         = object.relation_type.title         if object.relation_type && object.relation_type.title.present?
    data['title_reverse'] = object.relation_type.title_reverse if object.relation_type && object.relation_type.title_reverse.present?
    data
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
