class ActorSerializer < BaseSerializer
  cached
  self.version = 2

  attributes :id, :level, :name, :observation

  has_many :actor_localizations, key: :locations
  # Categories
  has_many :organization_types
  has_many :socio_cultural_domains
  has_many :other_domains

  def level
    case object.type
    when 'ActorMacro' then 'macro'
    when 'ActorMeso'  then 'meso'
    when 'ActorMicro' then 'micro'
    end
  end

  def attributes
    data = super
    if object.meso_or_macro?
      data['scale']         = object.operational_field_txt if object.macro?
      data['short_name']    = object.short_name
      data['legal_status']  = object.legal_status
      data['other_names']   = object.other_names
    elsif object.micro?
      data['title']         = object.title_txt
      data['gender']        = object.gender_txt
    end
    data
  end

  def include_associations!
    include! :actor_localizations,    serializer: RelationalLocalizationSerializer
    include! :organization_types,     serializer: CategorySerializer
    include! :socio_cultural_domains, serializer: CategorySerializer
    include! :other_domains,          serializer: CategorySerializer
  end

  def cache_key
    # For filter options
    cache_params = nil
    
    self.class.cache_key << [object, object.updated_at, cache_params]
  end
end
