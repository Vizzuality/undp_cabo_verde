class CategorySerializer < BaseSerializer
  cached
  self.version = 1

  attributes :id, :name, :type

  def type
    case object.type
    when 'OtherDomain'         then 'Other domains'
    when 'SocioCulturalDomain' then 'Socio cultural domain'
    end
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
