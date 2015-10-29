class ActorMicro < Actor
  has_many :actors_macro_micro_relations, foreign_key: :micro_id
  has_many :actors_meso_micro_relations, foreign_key: :micro_id

  has_many :macros, through: :actors_macro_micro_relations, dependent: :destroy
  has_many :mesos, through: :actors_meso_micro_relations, dependent: :destroy

  validates :title, presence: true, on: :update

  def gender_txt
    %w(Unisex Male Female)[gender - 1]
  end

  def title_txt
    %w(Mr Ms Mrs Miss Dr Prof Rev Other)[title - 1]
  end

  def birth
    date_of_birth.to_date if date_of_birth.present?
  end
end
