class IndicatorSerializer < BaseSerializer
  cached
  self.version = 6

  attributes :id, :name, :alternative_name

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
