class ActorMicro < Actor
  validates :title, presence: true, on: :update

  GENDERS = %w(Other Male Female)
  TITLES  = %w(Mr. Ms. Mrs. Miss Dr. Prof. Rev. Other Eng.)

  def gender_txt
    GENDERS[gender - 1]
  end

  def gender_select
    GENDERS.map.with_index(1).to_a
  end

  def title_txt
    TITLES[title - 1]
  end

  def title_select
    TITLES.map.with_index(1).to_a
  end

  def birth
    date_of_birth.to_date if date_of_birth.present?
  end

  def empty_relations?
    parents.empty?
  end
end
