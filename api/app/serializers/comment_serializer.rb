class CommentSerializer < BaseSerializer
  cached
  self.version = 9

  attributes :body, :date, :commentable_type, :commentable_id

  has_one :user

  def date
    object.created_at.to_time.iso8601
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
