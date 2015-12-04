class ActorMacro < Actor
  validates :operational_field, presence: true, on: :update

  OPERATIONAL_FIELDS = %w(Global International National)

  def operational_field_txt
    OPERATIONAL_FIELDS[operational_field - 1]
  end

  def empty_relations?
    parents.empty?
  end
end
