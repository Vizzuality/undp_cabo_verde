class RelationalLocalizationSerializer < BaseSerializer
  cached
  self.version = 5
  
  attribute  :id
  attributes :main, :start_date, :end_date

  has_one :localization, key: :info_data

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
