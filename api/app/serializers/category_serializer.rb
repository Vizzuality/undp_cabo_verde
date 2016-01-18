class CategorySerializer < BaseSerializer
  cached
  self.version = 6

  attributes :id, :name, :type, :slug

  def type
    case object.type
    when 'OrganizationType'    then 'Organization type'
    when 'OtherDomain'         then 'Other domains'
    when 'SocioCulturalDomain' then 'Socio cultural domain'
    end
  end

  def slug
    object.name.gsub(",","").gsub(" ","_").downcase
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
