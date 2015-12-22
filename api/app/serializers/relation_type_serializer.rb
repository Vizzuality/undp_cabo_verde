class RelationTypeSerializer < BaseSerializer
  cached
  self.version = 5

  attributes :title, :title_reverse

  def title
    object.title
  end

  def title_reverse
    object.title_reverse
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
