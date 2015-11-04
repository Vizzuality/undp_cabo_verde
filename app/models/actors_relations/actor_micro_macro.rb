class ActorMicroMacro < ActiveRecord::Base
  belongs_to :user

  belongs_to :macro, class_name: 'ActorMacro', foreign_key: :macro_id
  belongs_to :micro, class_name: 'ActorMicro', foreign_key: :micro_id
end
