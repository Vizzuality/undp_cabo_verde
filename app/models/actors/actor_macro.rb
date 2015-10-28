class ActorMacro < Actor

  has_many :macro_meso_relations, foreign_key: :macro_id
  has_many :macro_micro_relations, foreign_key: :macro_id

  has_many :mesos, through: :macro_meso_relations, dependent: :destroy
  has_many :micros, through: :macro_micro_relations, dependent: :destroy

end
