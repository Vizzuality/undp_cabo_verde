class MacroMesoRelation < ActiveRecord::Base
  belongs_to :macro, class_name: 'ActorMacro', foreign_key: :macro_id, touch: true
  belongs_to :meso, class_name: 'ActorMeso', foreign_key: :meso_id, touch: true
end
