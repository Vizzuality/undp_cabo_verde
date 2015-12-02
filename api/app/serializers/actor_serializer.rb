class ActorSerializer < BaseSerializer
  cached
  self.version = 1

  attributes :id, :level, :name, :observation

  has_many :localizations, key: :locations, serializer: LocalizationSerializer
  has_many :categories,    serializer: CategorySerializer

  def level
    case object.type
    when 'ActorMacro' then 'macro'
    when 'ActorMeso'  then 'meso'
    when 'ActorMicro' then 'micro'
    end
  end

  def attributes
    hash = super
    if object.meso_or_macro?
      hash['scale']         = object.operational_filed_txt if object.macro?
      hash['short_name']    = object.short_name
      hash['legal_status']  = object.legal_status
      hash['other_names']   = object.other_names
    elsif object.micro?
      hash['title']         = object.title_txt
      hash['gender']        = object.gender_txt
      hash['date_of_birth'] = object.birth
    end
    hash
  end

  def cache_key
    # For filter options
    cache_params = nil
    
    self.class.cache_key << [object, object.updated_at, localizations, cache_params]
  end
end
