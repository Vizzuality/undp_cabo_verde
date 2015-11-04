class ActorMesoMacro < ActiveRecord::Base
  belongs_to :user

  belongs_to :macro, class_name: 'ActorMacro', foreign_key: :macro_id
  belongs_to :meso, class_name: 'ActorMeso', foreign_key: :meso_id
end
