Rails.application.routes.draw do

  devise_for :users
  # # API routes
  # namespace :api, defaults: {format: 'json'} do

  #   # Set APIVersion.new(version: X, default: true) for dafault API version
  #   scope module: :v1, constraints: APIVersion.new(version: 1, current: true) do

  #     with_options only: [:index, :show] do |list_show_only|
  #     end

  #   end

  # end
  # # End API routes

  root 'home#index'

  # # API Documentation
  # mount Raddocs::App => "api/docs"
  # get 'api', to: redirect('api/docs')

end
