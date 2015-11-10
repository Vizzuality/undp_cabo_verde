class ActorRelation < ActiveRecord::Base
  belongs_to :user

  belongs_to :parent, class_name: 'Actor', foreign_key: :parent_id
  belongs_to :child, class_name: 'Actor', foreign_key: :child_id
end
