class ActorMacro < Actor
  has_many :macro_meso_relations, foreign_key: :macro_id
  has_many :macro_micro_relations, foreign_key: :macro_id

  has_many :mesos, through: :macro_meso_relations, dependent: :destroy
  has_many :micros, through: :macro_micro_relations, dependent: :destroy

  validates :operational_filed, presence: true, on: :update

  def operational_filed_txt
    %w(Global International National)[operational_filed - 1]
  end
end
