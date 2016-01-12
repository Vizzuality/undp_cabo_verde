module API::V1
  class DomainsController < API::ApplicationController
    def index
      @domains = Category.domain_categories.order(:name)

      respond_with @domains, each_serializer: CategorySerializer, root: 'domains',
        meta: { size: @domains.count }
    end
  end
end
