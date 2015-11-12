Rails.application.routes.draw do

  devise_for :users, path: 'account', path_names: { 
                                        sign_in: 'login', sign_out: 'logout', 
                                        password: 'secret', sign_up: 'register' 
                                      }, 
                                      controllers: {
                                        sessions: 'users/sessions',
                                        registrations: 'users/registrations',
                                        passwords: 'users/passwords'
                                      }

  devise_scope :user do
    post   'account/register', to: 'users/registrations#create', as: :register 
    post   'account/password', to: 'users/passwords#create',     as: :secret
    post   'account/edit',     to: 'users/registrations#edit',   as: :account_edit

    authenticated :user do
      root 'users#dashboard', as: :authenticated_root
    end
  end
  
  resources :users, except: [:destroy, :new, :create] do
    patch 'deactivate', on: :member
    patch 'activate',   on: :member
    patch 'make_admin', on: :member
    patch 'make_user',  on: :member
    resources :actors,  controller: 'users/actors', only: :index
  end

  resources :actors do
    resources :localizations, controller: 'localizations', except: :index do
      patch 'deactivate', on: :member
      patch 'activate',   on: :member
    end

    patch 'link_actor',   on: :member
    patch 'unlink_actor', on: :member

    get   'membership', on: :member
    get   'membership/:parent_id/edit', to: 'actor_relations#edit', as: :edit_actor_relation
  end

  resources :actor_micros, controller: 'actors', type: 'ActorMicro' do
    patch 'activate',     on: :member
    patch 'deactivate',   on: :member
  end

  resources :actor_mesos, controller: 'actors', type: 'ActorMeso' do
    patch 'activate',     on: :member
    patch 'deactivate',   on: :member
  end

  resources :actor_macros, controller: 'actors', type: 'ActorMacro' do
    patch 'activate',     on: :member
    patch 'deactivate',   on: :member
  end

  with_options only: :update do |is_only|
    is_only.resources :actor_relations, param: :relation_id
  end

  resources :categories
  
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
  # mount Raddocs::App => 'api/docs'
  # get 'api', to: redirect('api/docs')

end
