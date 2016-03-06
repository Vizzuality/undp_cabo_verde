class ActorsCategory < ActiveRecord::Base
  belongs_to :actor, touch: true
  belongs_to :category
end
