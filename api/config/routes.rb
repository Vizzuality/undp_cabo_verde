API::Engine.routes.draw do
  # API routes
  # Set APIVersion.new(version: X, default: true) for dafault API version
  scope module: :v1, constraints: APIVersion.new(version: 1, current: true), defaults: { format: 'json' } do
    with_options only: [:index, :show] do |list_show_only|
      list_show_only.resources :actors
      list_show_only.resources :acts, path: 'actions'
    end
  end
# End API routes
end