class RelationArraySerializer < BaseSerializer
  cached
  self.version = 9

  attributes :parent_id, :child_id

  def attributes
    data = super
    data['type']           = type
    data['start_location'] = parent_location
    data['end_location']   = child_location
    data
  end

  def type
    case object.class.name
    when 'ActRelation'      then 'Action-Action'
    when 'ActorRelation'    then 'Actor-Actor'
    when 'ActActorRelation' then 'Actor-Action'
    end
  end

  def parent_location
    data = {}
    data['lat']  = start_location.lat  if start_location
    data['long'] = start_location.long if start_location
    data
  end

  def child_location
    data = {}
    data['lat']  = end_location.lat  if end_location
    data['long'] = end_location.long if end_location
    data
  end

  def start_location
    object.find_parent_location
  end

  def end_location
    object.find_child_location
  end

  def cache_key
    self.class.cache_key << [object]
  end
end
