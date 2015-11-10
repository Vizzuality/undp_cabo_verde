class ActorMicro < Actor
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

  def empty_relations?
    parents.empty?
  end
end
