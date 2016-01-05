module API::V1
  class ActorsController < API::ApplicationController
    before_action :set_actor, only: :show

    def index
      @search = Search::Actors.new(params)
      @actors = @search.results
      respond_with @actors, each_serializer: ActorArraySerializer, root: 'actors', meta: { size: @search.total_cnt, cache_date: @actors.last_max_update }
    end

    def show
      respond_with @actor, serializer: ActorSerializer
    end

    private

      def set_actor
        @actor = Actor.find(params[:id])
      end
  end
end
