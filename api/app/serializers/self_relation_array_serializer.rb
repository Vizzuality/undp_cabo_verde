class SelfRelationArraySerializer < BaseSerializer
  cached
  self.version = 9

  attributes :id, :name, :level, :locations, :info

  def level
    type = object.type
    case true
    when type.include?('Macro') then 'macro'
    when type.include?('Meso')  then 'meso'
    when type.include?('Micro') then 'micro'
    end
  end

  def attributes
    data = super
    if !object.is_actor?
      data['start_date'] = object.start_date.to_date.iso8601 if object.start_date.present?
      data['end_date']   = object.end_date.to_date.iso8601   if object.end_date.present?
    end
    data
  end

  def locations
    if @options[:search_filter]['start_date'].present? || @options[:search_filter]['end_date'].present?
      object.get_locations_by_date(@options[:search_filter]).map do |object_localizations|
        LocalizationArraySerializer.new(object_localizations, root: false).serializable_hash
      end
    else
      object.get_locations.map do |localizations|
        LocalizationArraySerializer.new(localizations, root: false).serializable_hash
      end
    end
  end

  def info
    type = object.class.name
    case true
    when type.include?('Actor') && options[:child_id].present?  then RelationInfoSerializer.new(object.actor_relations_as_parent.find_by(parent_id: object.id, child_id: options[:child_id])).serializable_hash
    when type.include?('Actor') && options[:parent_id].present? then RelationInfoSerializer.new(object.actor_relations_as_child.find_by(parent_id: options[:parent_id], child_id: object.id)).serializable_hash
    when type.include?('Act')   && options[:child_id].present?  then RelationInfoSerializer.new(object.act_relations_as_parent.find_by(parent_id: object.id, child_id: options[:child_id])).serializable_hash
    when type.include?('Act')   && options[:parent_id].present? then RelationInfoSerializer.new(object.act_relations_as_child.find_by(parent_id: options[:parent_id], child_id: object.id)).serializable_hash
    end
  end

  def cache_key
    cache_params = @options[:search_filter] if @options[:search_filter].present?
    self.class.cache_key << [object, object.updated_at, cache_params]
  end
end
