class ActionMeso < Action
  def empty_relations?
    parents.empty?
  end
end
