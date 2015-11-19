class ActMicro < Act
  def empty_relations?
    parents.empty?
  end
end
