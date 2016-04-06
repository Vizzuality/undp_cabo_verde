module API::V1
  class ActorsController < API::ApiBaseController
    before_action :set_actor, only: :show
    before_action :set_search_filter, only: [:index, :show]

    def index
      @search = Search::Actors.new(params, paged)
      @actors = @search.results.filter_actives.order(:name)
      respond_with @actors, each_serializer: ActorArraySerializer, root: 'actors', search_filter: @search_filter, meta: { size: @search.total_cnt, cache_date: @actors.last_max_update }
    end

    def show
      respond_with @actor, serializer: ActorSerializer, search_filter: @search_filter
    end

    private

      def set_actor
        @actor = Actor.find(params[:id])
      end

      def set_search_filter
        @search_filter = {}
        @search_filter['levels']      = params[:levels]      if params[:levels].present?
        @search_filter['domains_ids'] = params[:domains_ids] if params[:domains_ids].present?
        @search_filter['start_date']  = params[:start_date]  if params[:start_date].present?
        @search_filter['end_date']    = params[:end_date]    if params[:end_date].present?
      end

      def paged
        params[:page].present?
      end
  end
end
