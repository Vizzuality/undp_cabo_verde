class ActorMicroMeso < ActiveRecord::Base
  belongs_to :user

  belongs_to :meso, class_name: 'ActorMeso', foreign_key: :meso_id
  belongs_to :micro, class_name: 'ActorMicro', foreign_key: :micro_id
end
