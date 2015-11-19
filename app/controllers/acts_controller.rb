class ActsController < ApplicationController
  load_and_authorize_resource param_method: :act_params
  
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_current_user, only: [:create, :link_act]
  before_action :set_act, except: [:index, :new, :create]
  before_action :act_filters, only: :index
  before_action :set_type
  before_action :set_selection, only: [:new, :edit]
  before_action :set_parents, only: :membership
  before_action :set_memberships, only: [:show, :membership]
  
  def index
    @acts = if current_user && current_user.admin?
              type_class.filter_acts(act_filters)
            else
              type_class.filter_actives
            end
  end

  def show
    @localizations = @act.localizations
    @categories = @act.categories
  end

  def edit
  end

  def new
    @act = type_class.new
  end

  def update
    if @act.update(act_params)
      update_act_flow
    else
      render :edit
    end
  end

  def create
    @act = @user.acts.build(act_params)
    if @act.save
      redirect_to edit_act_path(@act)
    else
      render :new
    end
  end

  def membership
  end

  def deactivate
    if @act.try(:deactivate)
      redirect_to acts_path
    end
  end

  def activate
    if @act.try(:activate)
      redirect_to acts_path
    end
  end

  def destroy
    @act.destroy
    redirect_to acts_path
  end

  def link_act
    @user.act_relations.create!(child_id: @act.id, parent_id: params[:parent_id])
    link_act_flow
  end

  def unlink_act
    @relation = ActRelation.find_by(child_id: @act.id, parent_id: params[:parent_id])
    @relation.destroy
    link_act_flow
  end

  private
  
    def set_type
      @type = type
    end

    def type
      Act.types.include?(params[:type]) ? params[:type] : 'Act'
    end

    def type_class
      type.constantize
    end

    def act_filters
      params.permit(:active)
    end

    def set_current_user
      @user = current_user
    end

    def set_act
      @act = type_class.find(params[:id])
    end

    def set_selection
      @types      = type_class.types.map { |t| [t("types.#{t.constantize}", default: t.constantize), t.camelize] }
      @macros     = ActMacro.filter_actives
      @mesos      = ActMeso.filter_actives
      @categories = Category.all
    end

    def set_parents
      # ToDo: change it to search function
      @all_macros = Act.filter_actives.not_macros_parents(@act) unless @act.macro?
      @all_mesos  = Act.filter_actives.not_mesos_parents(@act)  if @act.micro?
    end

    def set_memberships
      @macros = @act.macros_parents
      @mesos  = @act.mesos_parents
      @micros = @act.micros_parents
    end

    def update_act_flow
      if @act.micro_or_meso? && @act.empty_relations?
        redirect_to membership_act_path(@act)
      else
        redirect_to act_path(@act)
      end
    end

    def link_act_flow
      if @act.micro?
        redirect_to membership_act_path(@act)
      else
        redirect_to membership_act_path(@act)
      end
    end

    def act_params
      params.require(type.underscore.to_sym).permit!
    end

    def menu_highlight
      @menu_highlighted = :acts
    end
end