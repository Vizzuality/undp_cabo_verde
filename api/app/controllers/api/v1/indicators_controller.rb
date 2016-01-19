module API::V1
  class IndicatorsController < API::ApiBaseController
    before_action :set_indicator, only: :show

    def index
      @indicators = Indicator.filter_actives.recent
      respond_with @indicators, each_serializer: IndicatorSerializer, root: 'artifacts', meta: { size: @indicators.size, cache_date: @indicators.last_max_update }
    end

    def show
      respond_with @indicator, serializer: IndicatorMainSerializer, root: 'artifact'
    end

    private

      def set_indicator
        @indicator = Indicator.find(params[:id])
      end
  end
end
