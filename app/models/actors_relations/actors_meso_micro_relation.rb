class ActorsMesoMicroRelation < ActiveRecord::Base
  belongs_to :meso, class_name: 'ActorMeso', foreign_key: :meso_id, touch: true
  belongs_to :micro, class_name: 'ActorMicro', foreign_key: :micro_id, touch: true
end
