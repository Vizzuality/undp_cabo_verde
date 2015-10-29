class ActorMicro < Actor

  has_many :macro_micro_relations, foreign_key: :micro_id
  has_many :meso_micro_relations, foreign_key: :micro_id

  has_many :macros, through: :macro_micro_relations, dependent: :destroy
  has_many :mesos, through: :meso_micro_relations, dependent: :destroy

  validates :title, presence: true, on: :update

  def gender_txt
    ['Unisex', 'Male', 'Female'][self.gender - 1]
  end

  def title_txt
    ['Mr', 'Ms', 'Mrs', 'Miss', 'Dr', 'Prof', 'Rev', 'Other - please state'][self.title - 1]
  end

  def birth
    date_of_birth.to_date if date_of_birth.present?
  end

end