class ActArraySerializer < BaseSerializer
  cached
  self.version = 7

  attributes :id, :name, :level

  has_many :localizations, key: :locations

  def level
    case object.type
    when 'ActMacro' then 'macro'
    when 'ActMeso'  then 'meso'
    when 'ActMicro' then 'micro'
    end
  end

  def attributes
    data = super
    data['start_date'] = object.start_date.to_date.iso8601 if object.start_date
    data['end_date']   = object.end_date.to_date.iso8601   if object.end_date
    data
  end

  def include_associations!
    include! :localizations, serializer: LocalizationArraySerializer
  end

  def cache_key
    cache_params = @options[:search_filter] if @options[:search_filter].present?
    self.class.cache_key << [object, object.updated_at, cache_params]
  end
end
