class ActMeso < Act
  def empty_relations?
    parents.empty?
  end
end
