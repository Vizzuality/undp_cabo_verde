Rails.application.routes.draw do

  get 'prototype' => 'prototype#index'

  devise_for :users, path: 'account', path_names: {
                                        sign_in: 'login', sign_out: 'logout',
                                        password: 'secret', sign_up: 'register'
                                      },
                                      controllers: {
                                        sessions: 'users/sessions',
                                        registrations: 'users/registrations',
                                        passwords: 'users/passwords'
                                      }

  scope :account do
    devise_scope :user do
      post 'register',  to: 'users/registrations#create', as: :register
      post 'password',  to: 'users/passwords#create',     as: :secret
      post 'edit',      to: 'users/registrations#edit',   as: :account_edit
    end
  end

  get  'dashboard', to: 'users#dashboard', as: :dashboard

  scope :manage do
    resources :users, except: [:destroy, :new, :create] do
      patch 'deactivate', on: :member
      patch 'activate',   on: :member
      patch 'make_admin', on: :member
      patch 'make_user',  on: :member
      resources :actors,  controller: 'users/actors',  only: :index
      resources :acts, controller: 'users/acts', only: :index
    end

    # Actors
    resources :actors do
      resources :localizations, controller: 'localizations', except: :index do
        patch 'deactivate', on: :member
        patch 'activate',   on: :member
      end

      resources :comments, only: [:create, :activate, :deactivate] do
        patch 'deactivate', on: :member
        patch 'activate',   on: :member
      end

      patch 'link_actor',   on: :member
      patch 'unlink_actor', on: :member

      get   'membership', on: :member
      get   'membership/:parent_id/edit', to: 'actor_relations#edit', as: :edit_actor_relation
    end

    resources :actor_micros, controller: 'actors', type: 'ActorMicro' do
      patch 'activate',   on: :member
      patch 'deactivate', on: :member
    end

    resources :actor_mesos, controller: 'actors', type: 'ActorMeso' do
      patch 'activate',   on: :member
      patch 'deactivate', on: :member
    end

    resources :actor_macros, controller: 'actors', type: 'ActorMacro' do
      patch 'activate',   on: :member
      patch 'deactivate', on: :member
    end

    with_options only: :update do |is_only|
      is_only.resources :actor_relations, param: :relation_id
    end
    # End Actors

    # Acts
    resources :acts, path: 'actions' do
      resources :localizations, controller: 'localizations', except: :index do
        patch 'deactivate', on: :member
        patch 'activate',   on: :member
      end

      resources :comments, only: [:create, :activate, :deactivate] do
        patch 'deactivate', on: :member
        patch 'activate',   on: :member
      end

      patch 'link_act',   on: :member
      patch 'unlink_act', on: :member

      get   'membership', on: :member
      get   'membership/:parent_id/edit', to: 'act_relations#edit', as: :edit_act_relation
    end

    resources :act_micros, controller: 'acts', type: 'ActMicro' do
      patch 'activate',    on: :member
      patch 'deactivate',  on: :member
    end

    resources :act_mesos, controller: 'acts', type: 'ActMeso' do
      patch 'activate',    on: :member
      patch 'deactivate',  on: :member
    end

    resources :act_macros, controller: 'acts', type: 'ActMacro' do
      patch 'activate',    on: :member
      patch 'deactivate',  on: :member
    end

    with_options only: :update do |is_only|
      is_only.resources :act_relations, param: :relation_id
    end
    # End Acts

    # Categories
    resources :categories
    resources :socio_cultural_domains, controller: 'categories', type: 'SocioCulturalDomain'
    resources :other_domains,          controller: 'categories', type: 'OtherDomain'
    resources :organization_types,     controller: 'categories', type: 'OrganizationType'
    resources :operational_fields,     controller: 'categories', type: 'OperationalField'

    # Relation types
    resources :relation_types, except: :show, path: 'relation-types'
  end

  root 'home#index'

  # API
  mount API::Engine, at: 'api'

  # API Documentation
  mount Raddocs::App => 'api/docs'
  get 'api', to: redirect('api/docs')

end
