class ActionMicro < Action
  def empty_relations?
    parents.empty?
  end
end
