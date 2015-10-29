class ActorMeso < Actor
  has_many :actors_macro_meso_relations, foreign_key: :meso_id
  has_many :actors_meso_micro_relations, foreign_key: :meso_id

  has_many :macros, through: :actors_macro_meso_relations, dependent: :destroy
  has_many :micros, through: :actors_meso_micro_relations, dependent: :destroy
end
