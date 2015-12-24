class ActArraySerializer < BaseSerializer
  cached
  self.version = 5

  attributes :id, :name, :level

  has_many :localizations, key: :locations

  def level
    case object.type
    when 'ActMacro' then 'macro'
    when 'ActMeso'  then 'meso'
    when 'ActMicro' then 'micro'
    end
  end

  def include_associations!
    include! :localizations, serializer: LocalizationArraySerializer
  end

  def cache_key
    # For filter options
    cache_params = nil
    
    self.class.cache_key << [object, object.updated_at, cache_params]
  end
end
