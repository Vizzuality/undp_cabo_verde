module API::V1
  class ActorsController < API::ApplicationController
    def index
      @actors = Actor.all
      respond_with @actors, each_serializer: ActorArraySerializer
    end

    def show
      @actor = Actor.find(params[:id])
      respond_with @actor, serializer: ActorSerializer
    end
  end
end