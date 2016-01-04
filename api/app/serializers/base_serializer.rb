class BaseSerializer < ActiveModel::Serializer
  class_attribute :version
  self.version = 5
  
  def self.cache_key
    ['version', self.version]
  end
end