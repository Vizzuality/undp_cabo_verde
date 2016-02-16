class ActorsController < ApplicationController
  include FavouriteActions
  before_action :current_object,  only: [:create_favourite, :destroy_favourite]

  before_action :store_location
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_current_user, only: [:create, :link_actor]
  before_action :set_actor, except: [:index, :new, :create, :show, :edit]
  before_action :set_actor_preload, only: [:show, :edit]
  before_action :actor_filters, only: :index
  before_action :set_type
  before_action :set_selection, only: [:new, :edit, :show, :create, :update]
  before_action :set_selection_index, only: :index
  before_action :set_micro_selection, only: [:new, :create]
  before_action :set_parents, only: :membership
  before_action :set_parents_locations, only: [:show, :edit, :update]
  before_action :set_memberships, only: [:show, :membership]

  def index
    @search = Search::Actors.new(search_params)
    @actors = @search.results
    @actors = if current_user && current_user.admin?
                @actors.order(:name).filter_actors(actor_filters).page params[:page]
              else
                @actors.order(:name).page params[:page]
              end
  end

  def show
  end

  def edit
  end

  def new
    @actor = type_class.new
  end

  def update
    if @actor.update(actor_params)
      update_actor_flow
    else
      render :edit
    end
  end

  def create
    @actor = @user.actors.build(actor_params)
    if @actor.save
      update_actor_flow
    else
      render :new
    end
  end

  def membership
  end

  def deactivate
    if @actor.try(:deactivate)
      redirect_to actors_path
    end
  end

  def activate
    if @actor.try(:activate)
      redirect_to actors_path
    end
  end

  def destroy
    @actor.destroy
    redirect_to actors_path
  end

  def link_actor
    @user.actor_relations.create!(child_id: @actor.id, parent_id: params[:parent_id])
    link_actor_flow
  end

  def unlink_actor
    @relation = ActorRelation.find_by(child_id: @actor.id, parent_id: params[:parent_id])
    @relation.destroy
    link_actor_flow
  end

  private

    def set_type
      @type = type
    end

    def type
      Actor.types.include?(params[:type]) ? params[:type] : 'Actor'
    end

    def type_class
      type.constantize
    end

    def actor_filters
      params.permit(:active)
    end

    def set_current_user
      @user = current_user
    end

    def set_actor
      @actor = type_class.find(params[:id])
    end

    def current_object
      @object = Actor.find(params[:id])
    end

    def set_actor_preload
      @actor = type_class.preload(:localizations).find(params[:id])
    end

    def set_selection
      @types          = type_class.types.map { |t| [t("types.#{t.constantize}", default: t.constantize), t.camelize] }
      @macros         = ActorMacro.order(:name).filter_actives
      @mesos          = ActorMeso.order(:name).filter_actives
      @actor_relation_types   = RelationType.order(:title).includes_actor_relations.collect     { |rt| [ rt.title, rt.id ] }
      @action_relation_types  = RelationType.order(:title).includes_actor_act_relations.collect { |rt| [ rt.title, rt.id ] }
      @organization_types     = Category.ot_categories
      @socio_cultural_domains = Category.scd_categories
      @other_domains          = Category.od_categories
      @merged_domains         = Category.domain_categories
      @operational_fields     = Category.of_categories
      @parents_to_select      = Actor.exclude_self_for_select(@actor).exclude_parents_for_select(@actor)
      @children_to_select     = Actor.exclude_self_for_select(@actor).exclude_children_for_select(@actor)
      @actions_to_select      = Act.exclude_related_actions(@actor)

      @all_parents_to_select  = Actor.order(:name).filter_actives
      @all_children_to_select = Actor.order(:name).filter_actives
      @all_actions_to_select  = Act.order(:name).filter_actives
    end

    def set_selection_index
      @types      = ['macro', 'meso', 'micro']
      @categories = Category.domain_categories
    end

    def set_micro_selection
      @title_select  = ActorMicro.new.title_select
      @gender_select = ActorMicro.new.gender_select

    end

    def set_parents_locations
      @parent_locations = @actor.parents_locations || [] if @actor.micro?
    end

    def set_parents
      # ToDo: change it to search function
      @all_macros = Actor.order(:name).filter_actives.not_macros_parents(@actor)
      @all_mesos  = Actor.order(:name).filter_actives.not_mesos_parents(@actor) if @actor.micro_or_meso?
    end

    def set_memberships
      @macros  = @actor.macros_parents
      @mesos   = @actor.mesos_parents
      @micros  = @actor.micros_parents
      @actions = @actor.acts.filter_actives
    end

    def update_actor_flow
      redirect_to actor_path(@actor)
    end

    def link_actor_flow
      if @actor.micro?
        redirect_to membership_actor_path(@actor)
      else
        redirect_to membership_actor_path(@actor)
      end
    end

    def actor_params
      params.require(type.underscore.to_sym).permit!
    end

    def search_params
      params.permit(:search_term, domains_ids: [], levels: [])
    end

    def menu_highlight
      @menu_highlighted = :actors
    end
end
