class ActSerializer < BaseSerializer
  cached
  self.version = 7

  attributes :id, :level, :name, :alternative_name, :short_name, :description

  # Actor relations below: def actors
  # Action relations below: def actions
  # Locations
  has_many :localizations, key: :locations

  # Comments
  has_many :comments

  # Indicators and measurements
  has_many :act_indicator_relations, key: :artifacts

  # Categories
  has_many :organization_types
  has_many :socio_cultural_domains
  has_many :other_domains

  def level
    case object.type
    when 'ActMacro' then 'macro'
    when 'ActMeso'  then 'meso'
    when 'ActMicro' then 'micro'
    end
  end

  def attributes
    data = super
    data['human_or_natural']  = object.human? ? 'human' : 'natural'
    data['event_or_activity'] = object.event? ? 'event' : 'activity'
    data['start_date']        = object.start_date.to_date.iso8601 if object.start_date
    data['end_date']          = object.end_date.to_date.iso8601   if object.end_date
    data['budget']            = budget
    data['actions']           = actions
    data['actors']            = actors
    data
  end

  def budget
    data = {}
    data['currency']        = object.budget.currency.iso_code            if object.budget.currency.iso_code
    data['currency_symbol'] = object.budget.currency.html_entity         if object.budget.currency.html_entity
    data['value']           = '%.2f' % (object.budget.fractional * 0.01) if object.budget.fractional
    data
  end

  def actions
    data = {}
    data['parents']       = object.parents.sort_by { |parent| parent['id'] }.map do |parent|
                              SelfRelationArraySerializer.new(parent, root: :parents, search_filter: @options[:search_filter]).serializable_hash
                            end

    data['parents_info']  = object.act_relations_as_child.sort_by { |parent| parent['parent_id'] }.map do |parent|
                              SelfRelationSerializer.new(parent, root: :parent_info).serializable_hash
                            end

    data['children']      = object.children.sort_by { |child| child['id'] }.map do |child|
                              SelfRelationArraySerializer.new(child, root: :children, search_filter: @options[:search_filter]).serializable_hash
                            end

    data['children_info'] = object.act_relations_as_parent.sort_by { |child| child['child_id'] }.map do |child|
                              SelfRelationSerializer.new(child, root: :children_info).serializable_hash
                            end
    data
  end

  def actors
    data = {}
    data['parents']      = object.actors.sort_by { |actor| actor['id'] }.map do |actor|
                             ActActorRelationArraySerializer.new(actor, root: :actors, search_filter: @options[:search_filter]).serializable_hash
                           end

    data['parents_info'] = object.act_actor_relations.sort_by { |relation| relation['actor_id'] }.map do |relation|
                             ActActorRelationSerializer.new(relation, root: :actors_info).serializable_hash
                           end
    data
  end

  def include_associations!
    include! :act_indicator_relations, serializer: ActIndicatorSerializer
    include! :localizations,           serializer: LocalizationSerializer
    include! :organization_types,      serializer: CategorySerializer
    include! :socio_cultural_domains,  serializer: CategorySerializer
    include! :other_domains,           serializer: CategorySerializer
    include! :comments,                serializer: CommentSerializer
  end

  def cache_key
    cache_params = @options[:search_filter] if @options[:search_filter].present?
    self.class.cache_key << [object, object.updated_at, cache_params]
  end
end
