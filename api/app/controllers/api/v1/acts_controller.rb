module API::V1
  class ActsController < API::ApiBaseController
    before_action :set_act, only: :show
    before_action :set_search_filter, only: [:index, :show]

    def index
      @search = Search::Acts.new(params)
      @acts = @search.results.filter_actives
      respond_with @acts, each_serializer: ActArraySerializer, root: 'actions', search_filter: @search_filter, meta: { size: @search.total_cnt, cache_date: @acts.last_max_update }
    end

    def show
      respond_with @act, serializer: ActSerializer, root: 'action', search_filter: @search_filter
    end

    private

      def set_act
        @act = Act.find(params[:id])
      end

      def set_search_filter
        @search_filter = {}
        @search_filter['levels']      = params[:levels]      if params[:levels].present?
        @search_filter['domains_ids'] = params[:domains_ids] if params[:domains_ids].present?
        @search_filter['start_date']  = params[:start_date]  if params[:start_date].present?
        @search_filter['end_date']    = params[:end_date]    if params[:end_date].present?
      end
  end
end
