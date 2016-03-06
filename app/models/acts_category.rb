class ActsCategory < ActiveRecord::Base
  belongs_to :act
  belongs_to :category
end
