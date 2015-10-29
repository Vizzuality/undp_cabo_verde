class ActorsMacroMicroRelation < ActiveRecord::Base
  belongs_to :macro, class_name: 'ActorMacro', foreign_key: :macro_id, touch: true
  belongs_to :micro, class_name: 'ActorMicro', foreign_key: :micro_id, touch: true
end
