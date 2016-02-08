class ActorSerializer < BaseSerializer
  cached
  self.version = 8

  attributes :id, :level, :name, :observation, :locations

  has_many :comments

  # Actors relations below: def actors
  # Actions relations below: def actions
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
    data['actors']          = actors
    data['actions']         = actions
    data
  end

  def actors
    data = {}
    data['parents']  = object.get_parents_by_date(@options[:search_filter]).sort_by { |parent| parent['id'] }.map do |parent|
                         SelfRelationArraySerializer.new(parent, root: :parents, search_filter: @options[:search_filter], child_id: object.id).serializable_hash
                       end

    data['children'] = object.get_children_by_date(@options[:search_filter]).sort_by { |child| child['id'] }.map do |child|
                         SelfRelationArraySerializer.new(child, root: :children, search_filter: @options[:search_filter], parent_id: object.id).serializable_hash
                       end
    data
  end

  def actions
    data = {}
    data['children'] = object.get_actions_by_date(@options[:search_filter]).sort_by { |action| action['id'] }.map do |action|
                         ActActorRelationArraySerializer.new(action, root: :actions, search_filter: @options[:search_filter], actor_id: object.id).serializable_hash
                       end
    data
  end

  def locations
    if @options[:search_filter]['start_date'].present? || @options[:search_filter]['end_date'].present?
      object.get_locations_by_date(@options[:search_filter]).map do |object_localizations|
        LocalizationSerializer.new(object_localizations, root: false).serializable_hash
      end
    else
      object.get_locations.map do |object_localizations|
        LocalizationSerializer.new(object_localizations, root: false).serializable_hash
      end
    end
  end

  def include_associations!
    include! :organization_types,     serializer: CategorySerializer
    include! :socio_cultural_domains, serializer: CategorySerializer
    include! :other_domains,          serializer: CategorySerializer
    include! :comments,               serializer: CommentSerializer
  end

  def cache_key
    cache_params = @options[:search_filter] if @options[:search_filter].present?
    self.class.cache_key << [object, object.updated_at, cache_params]
  end
end
