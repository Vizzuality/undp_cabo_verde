class Unit < ActiveRecord::Base
  has_many :act_indicator_relations
  has_many :measurements
end
