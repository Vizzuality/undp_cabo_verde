class ActorMeso < Actor
  def empty_relations?
    children.empty?
  end
end
