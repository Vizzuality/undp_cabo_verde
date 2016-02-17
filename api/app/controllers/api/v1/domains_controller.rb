module API::V1
  class DomainsController < API::ApiBaseController
    def index
      @domains = Category.domain_categories.order(:name)

      respond_with @domains, each_serializer: CategorySerializer, root: 'domains', meta: { size: @domains.size }
    end
  end
end
