class ActorSerializer < BaseSerializer
  cached
  self.version = 7

  attributes :id, :level, :name, :observation

  # Locations
  has_many :localizations, key: :locations
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
    data['parents']       = object.parents.sort_by { |parent| parent['id'] }.map do |parent|
                              SelfRelationArraySerializer.new(parent, root: :parents).serializable_hash
                            end

    data['parents_info']  = object.actor_relations_as_child.sort_by { |parent| parent['parent_id'] }.map do |parent|
                              SelfRelationSerializer.new(parent, root: :parent_info).serializable_hash
                            end

    data['children']      = object.children.sort_by { |child| child['id'] }.map do |child|
                              SelfRelationArraySerializer.new(child, root: :children).serializable_hash
                            end

    data['children_info'] = object.actor_relations_as_parent.sort_by { |child| child['child_id'] }.map do |child|
                              SelfRelationSerializer.new(child, root: :children_info).serializable_hash
                            end
    data
  end

  def actions
    data = {}
    data['children']      = object.acts.sort_by { |action| action['id'] }.map do |action|
                              ActActorRelationArraySerializer.new(action, root: :actions).serializable_hash
                            end

    data['children_info'] = object.act_actor_relations.sort_by { |relation| relation['act_id'] }.map do |relation|
                              ActActorRelationSerializer.new(relation, root: :actions_info).serializable_hash
                            end
    data
  end

  def include_associations!
    include! :localizations,          serializer: LocalizationSerializer
    include! :organization_types,     serializer: CategorySerializer
    include! :socio_cultural_domains, serializer: CategorySerializer
    include! :other_domains,          serializer: CategorySerializer
    include! :comments,               serializer: CommentSerializer
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
