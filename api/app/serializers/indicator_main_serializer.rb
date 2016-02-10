class IndicatorMainSerializer < BaseSerializer
  cached
  self.version = 9

  attributes :id, :name, :alternative_name

  # Actions
  has_many :acts, key: :actions
  has_many :comments

  def include_associations!
    include! :acts,     serializer: ActArraySerializer
    include! :comments, serializer: CommentSerializer
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
