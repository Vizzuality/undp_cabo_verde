class LocalizationArraySerializer < BaseSerializer
  cached
  self.version = 9

  attributes :id, :lat, :long, :main

  def attributes
    data = super
    data['start_date'] = object.start_date.to_date.iso8601 if object.start_date.present?
    data['end_date']   = object.end_date.to_date.iso8601   if object.end_date.present?
    data
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
