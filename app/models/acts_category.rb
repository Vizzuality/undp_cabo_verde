class ActsCategory < ActiveRecord::Base
  belongs_to :act, touch: true
  belongs_to :category
end
