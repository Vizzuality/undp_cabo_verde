class ActIndicatorSerializer < BaseSerializer
  cached
  self.version = 9

  attributes :target_value, :unit

  has_one  :indicator
  has_many :measurements

  def attributes
    data = super
    data['start_date'] = object.start_date.to_date.iso8601 if object.start_date.present?
    data['end_date']   = object.end_date.to_date.iso8601   if object.end_date.present?
    data['deadline']   = object.deadline.to_date.iso8601   if object.deadline.present?
    data
  end

  def unit
    data = {}
    data['name']   = object.unit.name   if object.unit
    data['symbol'] = object.unit.symbol if object.unit
    data
  end

  def include_associations!
    include! :indicator,    serializer: IndicatorSerializer
    include! :measurements, serializer: MeasurementSerializer
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
