class IndicatorMainSerializer < BaseSerializer
  cached
  self.version = 5

  attributes :id, :name, :alternative_name

  # Actions
  has_many :acts, key: :actions

  def include_associations!
    include! :acts, serializer: ActArraySerializer
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
