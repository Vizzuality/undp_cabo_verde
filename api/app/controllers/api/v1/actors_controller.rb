module API::V1
  class ActorsController < API::ApplicationController
    before_action :set_actor, only: :show

    def index
      @actors = Actor.filter_actives.recent.includes(:localizations)
      respond_with @actors, each_serializer: ActorArraySerializer, root: 'actors', meta: { size: @actors.size, cache_date: @actors.last_max_update }
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