class ActorMicro < Actor

  has_many :macro_micro_relations, foreign_key: :micro_id
  has_many :meso_micro_relations, foreign_key: :micro_id

  has_many :macros, through: :macro_micro_relations, dependent: :destroy
  has_many :mesos, through: :meso_micro_relations, dependent: :destroy

end
