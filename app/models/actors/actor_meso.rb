class ActorMeso < Actor

  has_many :macro_meso_relations, foreign_key: :meso_id
  has_many :meso_micro_relations, foreign_key: :meso_id

  has_many :macros, through: :macro_meso_relations, dependent: :destroy
  has_many :micros, through: :meso_micro_relations, dependent: :destroy

end
