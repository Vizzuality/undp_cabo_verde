module API::V1
  class DomainsController < API::ApplicationController
    def index
      @domains = Category.where(type: ['SocioCulturalDomain', 'OtherDomain']).
        order(:name)

      respond_with @domains, each_searializer: CategorySerializer, root: 'domains',
        meta: { size: @domains.count }
    end
  end
end
