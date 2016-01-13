class SelfRelationArraySerializer < BaseSerializer
  cached
  self.version = 6

  attributes :id, :name, :level

  has_many :localizations, key: :locations, serializer: LocalizationArraySerializer

  def level
    type = object.type
    case true
    when type.include?('Macro') then 'macro'
    when type.include?('Meso')  then 'meso'
    when type.include?('Micro') then 'micro'
    end
  end

  def cache_key
    # For filter options
    cache_params = nil
    
    self.class.cache_key << [object, object.updated_at, cache_params]
  end
end
