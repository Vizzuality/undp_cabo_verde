class RelationalLocalizationSerializer < BaseSerializer
  cached
  self.version = 6

  attributes :id, :main

  has_one :localization, key: :info_data

  def attributes
    data = super
    data['start_date'] = object.start_date.to_date.iso8601 if object.start_date
    data['end_date']   = object.end_date.to_date.iso8601   if object.end_date
    data
  end

  def id
    object.localization.id
  end

  def include_associations!
    include! :localization, serializer: LocalizationSerializer
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
