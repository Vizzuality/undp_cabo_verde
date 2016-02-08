class MeasurementSerializer < BaseSerializer
  cached
  self.version = 8

  attributes :id, :value, :unit, :details

  def attributes
    data = super
    data['date'] = object.date.to_date.iso8601 if object.date
    data
  end

  def unit
    data = {}
    data['name']   = object.unit.name   if object.unit
    data['symbol'] = object.unit.symbol if object.unit
    data
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
