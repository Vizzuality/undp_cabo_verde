class UserSerializer < BaseSerializer
  cached
  self.version = 9

  attributes :firstname, :lastname, :institution

  def cache_key
    self.class.cache_key << [object, object.updated_at]
  end
end
