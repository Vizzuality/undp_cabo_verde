class CategorySerializer < BaseSerializer
  cached
  self.version = 9

  attributes :id, :name, :type, :icon_identifier

  def type
    case object.type
    when 'OrganizationType'    then 'Organization type'
    when 'OtherDomain'         then 'Other domains'
    when 'SocioCulturalDomain' then 'Socio cultural domain'
    end
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
