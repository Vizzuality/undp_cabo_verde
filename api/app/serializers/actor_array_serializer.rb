class ActorArraySerializer < BaseSerializer
  cached
  self.version = 8

  attributes :id, :name, :level, :locations

  has_many :socio_cultural_domains
  has_many :other_domains

  def level
    case object.type
    when 'ActorMacro' then 'macro'
    when 'ActorMeso'  then 'meso'
    when 'ActorMicro' then 'micro'
    end
  end

  def locations
    if @options[:search_filter]['start_date'].present? || @options[:search_filter]['end_date'].present?
      object.get_locations_by_date(@options[:search_filter]).map do |actor_localizations|
        LocalizationArraySerializer.new(actor_localizations, root: false).serializable_hash
      end
    else
      object.get_locations.map do |actor_localizations|
        LocalizationArraySerializer.new(actor_localizations, root: false).serializable_hash
      end
    end
  end

  def include_associations!
    include! :socio_cultural_domains, serializer: CategorySerializer
    include! :other_domains,          serializer: CategorySerializer
  end

  def cache_key
    cache_params = @options[:search_filter] if @options[:search_filter].present?
    self.class.cache_key << [object, object.updated_at, cache_params]
  end
end
