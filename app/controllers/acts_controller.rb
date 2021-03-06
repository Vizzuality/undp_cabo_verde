class ActsController < ApplicationController
  before_action :store_location
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_current_user, only: [:create, :link_act]
  before_action :set_act, except: [:index, :new, :create, :show, :edit]
  before_action :set_act_preload, only: [:show, :edit]
  before_action :act_filters, only: :index
  before_action :set_type
  before_action :set_selection, only: [:new, :edit, :show, :create, :update]
  before_action :set_selection_index, only: :index
  before_action :set_parents, only: :membership
  before_action :set_memberships, only: [:show, :membership]

  def index
    @search = Search::Acts.new(search_params)
    @acts = @search.results
    @acts = if current_user && current_user.admin?
                @acts.order(:name).filter_acts(act_filters).page params[:page]
              else
                @acts.order(:name).page params[:page]
              end
  end

  def show
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
      update_act_flow
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

    def set_act_preload
      @act = type_class.preload(:localizations).find(params[:id])
    end

    def set_act
      @act = type_class.find(params[:id])
    end

    def set_selection
      @types      = type_class.types.map { |t| [t("types.#{t.constantize}", default: t.constantize), t.camelize] }
      @macros     = ActMacro.order(:name).filter_actives
      @mesos      = ActMeso.order(:name).filter_actives
      @organization_types     = Category.ot_categories
      @socio_cultural_domains = Category.scd_categories
      @other_domains          = Category.od_categories
      @merged_domains         = Category.domain_categories

      @parents_to_select      = Act.exclude_self_for_select(@act).exclude_parents_for_select(@act)
      @children_to_select     = Act.exclude_self_for_select(@act).exclude_children_for_select(@act)
      @actors_to_select       = Actor.exclude_related_actors(@act)
      @indicators_to_select   = Indicator.exclude_related_indicators(@act)

      @all_parents_to_select  = Act.order(:name).filter_actives
      @all_children_to_select = Act.order(:name).filter_actives
      @all_actors_to_select   = Actor.order(:name).filter_actives
      @all_indicators_to_select = Indicator.order(:name).filter_actives

      @units                  = Unit.order(:name)
      @actor_relation_types           = RelationType.order(:title).includes_actor_act_relations.collect     { |rt| [ rt.title_reverse, rt.id ] }
      @action_relation_types          = RelationType.order(:title).includes_act_relations.collect           { |rt| [ rt.title, rt.id ]         }
      @action_reverse_relation_types = RelationType.order(:title).includes_act_relations.collect           { |rt| [ rt.title_reverse, rt.id ] }
      @indicator_relation_types       = RelationType.order(:title).includes_act_indicator_relations.collect { |rt| [ rt.title, rt.id ]         }
    end

    def set_selection_index
      @types      = ['macro', 'meso', 'micro']
      @categories = Category.domain_categories
    end

    def set_parents
      # ToDo: change it to search function
      @all_macros = Act.filter_actives.not_macros_parents(@act)
      @all_mesos  = Act.filter_actives.not_mesos_parents(@act) if @act.micro_or_meso?
    end

    def set_memberships
      @macros = @act.macros_parents
      @mesos  = @act.mesos_parents
      @micros = @act.micros_parents
    end

    def update_act_flow
      redirect_to act_path(@act)
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

    def search_params
      params.permit(:search_term, domains_ids: [], levels: [])
    end

    def menu_highlight
      @menu_highlighted = :acts
    end
end
