module API::V1
  class RelationsController < API::ApiBaseController
    def index
    	@relations_objects = Relation.new
      @relations         = @relations_objects.get_relations

      respond_with @relations, each_serializer: RelationArraySerializer, root: 'relations', meta: { size: @relations.size }
    end
  end
end
