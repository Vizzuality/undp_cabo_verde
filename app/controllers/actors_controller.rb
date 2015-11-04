class ActorsController < ApplicationController
  load_and_authorize_resource
  
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_current_user, only: [:create, :link_macro, :link_meso]
  before_action :set_actor, except: [:index, :new, :create]
  before_action :actor_filters, only: :index
  before_action :set_type
  before_action :set_selection, only: [:new, :edit]
  before_action :set_parents, only: :membership
  # before_action :set_owned_parents, only: :show
  before_action :set_memberships, only: [:show, :membership]
  
  def index
    @actors = if current_user && current_user.admin?
               type_class.filter_actors(actor_filters)
             else
               type_class.filter_actives
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

  def link_macro
    if @actor.class.name.include?('ActorMicro')
      @user.actor_micro_macros.create!(micro_id: @actor.id, macro_id: params[:macro_id])
    else
      @user.actor_meso_macros.create!(meso_id: @actor.id, macro_id: params[:macro_id])
    end
    link_actor_flow
  end

  def unlink_macro
    @macro = if @actor.class.name.include?('ActorMicro')
              ActorMicroMacro.find(params[:relation_id])
            else
              ActorMesoMacro.find(params[:relation_id])
            end
    @macro.destroy
    link_actor_flow
  end

  def link_meso
    @user.actor_micro_mesos.create!(micro_id: @actor.id, meso_id: params[:meso_id])
    link_actor_flow
  end

  def unlink_meso
    @meso = ActorMicroMeso.find(params[:relation_id])
    @meso.destroy
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
      @types = type_class.types
      @macros = ActorMacro.filter_actives
      @mesos = ActorMeso.filter_actives
    end

    def set_parents
      # ToDo: change it to search function
      @all_macros = ActorMacro.filter_actives unless @actor.macro?
      @all_mesos  = ActorMeso.filter_actives  if @actor.micro?
    end

    def set_owned_parents
      @macros = @actor.macros unless @actor.macro?
      @mesos  = @actor.mesos  if @actor.micro?
    end

    def set_memberships
      @macros = @actor.actor_meso_macros.includes(:macro)  if @actor.meso?
      @macros = @actor.actor_micro_macros.includes(:macro) if @actor.micro?
      @mesos  = @actor.actor_micro_mesos.includes(:meso)   if @actor.micro?
    end

    def update_actor_flow
      if @actor.micro? && @actor.empty_relations?
        redirect_to membership_actor_micro_path(@actor)
      elsif @actor.meso? && @actor.empty_relations?
        redirect_to membership_actor_meso_path(@actor)
      else
        redirect_to actor_path(@actor)
      end
    end

    def link_actor_flow
      if @actor.micro?
        redirect_to membership_actor_micro_path(@actor)
      else
        redirect_to membership_actor_meso_path(@actor)
      end
    end

    def actor_params
      params.require(type.underscore.to_sym).permit!
    end

    def menu_highlight
      @menu_highlighted = :actors
    end
end
