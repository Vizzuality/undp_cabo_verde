class ActorMeso < Actor
  def empty_relations?
    parents.empty?
  end
end
