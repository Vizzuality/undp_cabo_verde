class ActorsCategory < ActiveRecord::Base
  belongs_to :actor
  belongs_to :category
end
