module API::V1
  class ActsController < API::ApplicationController
    before_action :set_act, only: :show
    before_action :set_search_filter, only: :index

    def index
      @search = Search::Acts.new(params)
      @acts = @search.results
      respond_with @acts, each_serializer: ActArraySerializer, root: 'actions', search_filter: @search_filter, meta: { size: @search.total_cnt, cache_date: @acts.last_max_update }
    end

    def show
      respond_with @act, serializer: ActSerializer, root: 'action'
    end

    private

      def set_act
        @act = Act.find(params[:id])
      end

      def set_search_filter
        @search_filter = {}
        @search_filter['levels']      = params[:levels]      if params[:levels].present?
        @search_filter['domains_ids'] = params[:domains_ids] if params[:domains_ids].present?
      end
  end
end
