class RelationInfoSerializer < BaseSerializer
  cached
  self.version = 12

  attributes :start_date, :end_date

  def attributes
    data = super
    data['start_date']    = object.start_date.to_date.iso8601  if object.start_date
    data['end_date']      = object.end_date.to_date.iso8601    if object.end_date
    data['title']         = object.relation_type.title         if object.relation_type.title.present?
    data['title_reverse'] = object.relation_type.title_reverse if object.relation_type.title_reverse.present?
    data
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end