module API::V1
  class ActsController < API::ApplicationController
    before_action :set_act, only: :show

    def index
      @search = Search::Acts.new(params)
      @acts = @search.results
      respond_with @acts, each_serializer: ActArraySerializer, root: 'actions', meta: { size: @search.total_cnt, cache_date: @acts.last_max_update }
    end

    def show
      respond_with @act, serializer: ActSerializer, root: 'action'
    end

    private

      def set_act
        @act = Act.find(params[:id])
      end
  end
end
