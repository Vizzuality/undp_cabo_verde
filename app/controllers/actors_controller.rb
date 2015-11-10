class ActorsController < ApplicationController
  load_and_authorize_resource
  
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_current_user, only: [:create, :link_actor]
  before_action :set_actor, except: [:index, :new, :create]
  before_action :actor_filters, only: :index
  before_action :set_type
  before_action :set_selection, only: [:new, :edit]
  before_action :set_parents, only: :membership
  before_action :set_memberships, only: [:show, :membership]
  
  def index
    @actors = if current_user && current_user.admin?
                type_class.filter_actors(actor_filters)
              else
                type_class.filter_actives
              end
  end

  def show
    @localizations = @actor.localizations
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
      redirect_to edit_actor_path(@actor)
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

    def set_selection
      @types = type_class.types.map { |t| [t("types.#{t.constantize}", default: t.constantize), t.camelize] }
      @macros = ActorMacro.filter_actives
      @mesos = ActorMeso.filter_actives
    end

    def set_parents
      # ToDo: change it to search function
      @all_macros = Actor.not_macros_parents(@actor) unless @actor.macro?
      @all_mesos  = Actor.not_mesos_parents(@actor)  if @actor.micro?
    end

    def set_memberships
      @macros = @actor.actor_relations_macros
      @mesos  = @actor.actor_relations_mesos
      # @micros = @actor.actor_relations_micros.includes(:parent)
    end

    def update_actor_flow
      if @actor.micro_or_meso? && @actor.empty_relations?
        redirect_to membership_actor_path(@actor)
      else
        redirect_to actor_path(@actor)
      end
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

    def menu_highlight
      @menu_highlighted = :actors
    end
end
