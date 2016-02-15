class FavouriteSerializer < BaseSerializer
  cached
  self.version = 9

  attributes :id, :user_id, :name, :uri, :favorable_type, :favorable_id, :date, :position

  def date
    object.updated_at.to_time.iso8601
  end

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
