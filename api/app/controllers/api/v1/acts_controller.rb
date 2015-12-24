module API::V1
  class ActsController < API::ApplicationController
    before_action :set_act, only: :show

    def index
      @acts = Act.filter_actives.recent.includes(:localizations)
      respond_with @acts, each_serializer: ActArraySerializer, root: 'actions', meta: { size: @acts.size, cache_date: @acts.last_max_update }
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
