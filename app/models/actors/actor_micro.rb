class ActorMicro < Actor
  has_many :actor_micro_macros, foreign_key: :micro_id
  has_many :actor_micro_mesos, foreign_key: :micro_id

  has_many :macros, through: :actor_micro_macros, dependent: :destroy
  has_many :mesos, through: :actor_micro_mesos, dependent: :destroy

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
