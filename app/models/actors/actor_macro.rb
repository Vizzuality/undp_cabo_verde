class ActorMacro < Actor
  validates :operational_filed, presence: true, on: :update

  def operational_filed_txt
    %w(Global International National)[operational_filed - 1]
  end

  def empty_relations?
    children.empty?
  end
end
