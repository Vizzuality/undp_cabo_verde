class Relation
	def initialize
    initialize_relations
  end

  def get_relations
  	@relations
  end

  private

    def initialize_relations
      @relations = ActorRelation.all | ActRelation.all | ActActorRelation.all
    end
end