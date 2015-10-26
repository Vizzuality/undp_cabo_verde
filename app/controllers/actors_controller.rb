class ActorsController < ApplicationController

  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_current_user, only: :create
  before_action :set_actor, only: [:show, :update, :destroy, :deactivate, :activate]
  before_action :actor_filters, only: :index
  before_action :set_type
  before_action :set_selection, only: [:new, :edit]

  load_and_authorize_resource
  
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
    @actor = type_class.find(params[:id])
    if @actor.update(actor_params)
      redirect_to actors_path
    else
      @actor.errors.messages.not_saved
      render :edit
    end
  end

  def create
    @actor = @user.actors.build(actor_params)
    if @actor.save
      redirect_to actor_path(@actor)
    else
      @actor.errors.messages.not_saved
      render :new
    end
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
      type_class.find(params[:id])
    end

    def set_selection
      @types = type_class.types.map { |a| [a.constantize, a.camelize] }
    end

    def actor_params
      if params[type.underscore.to_sym].nil?  || params[type.underscore.to_sym].empty?
        return false
      else
        return params.require(type.underscore.to_sym).permit!
      end
    end

    def menu_highlight
      @menu_highlighted = :actors
    end

end
