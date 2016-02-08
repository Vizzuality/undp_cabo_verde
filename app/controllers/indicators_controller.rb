class IndicatorsController < ApplicationController
  before_action :store_location
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_current_user, only: :create
  before_action :set_indicator, except: [:index, :new, :create]
  before_action :indicator_filters, only: :index
  before_action :set_selection, only: [:new, :edit, :show, :create, :update]
  before_action :set_memberships, only: :show

  def index
    @indicators = if current_user && current_user.admin?
                    Indicator.order(:name).filter_indicators(indicator_filters).page params[:page]
                  else
                    Indicator.order(:name).filter_actives.page params[:page]
                  end
  end

  def show
  end

  def edit
  end

  def new
    @indicator = Indicator.new
  end

  def update
    if @indicator.update(indicator_params)
      update_indicator_flow
    else
      render :edit
    end
  end

  def create
    @indicator = @user.indicators.build(indicator_params)
    if @indicator.save
      redirect_to indicators_path
    else
      render :new
    end
  end

  def deactivate
    if @indicator.try(:deactivate)
      redirect_to indicators_path
    end
  end

  def activate
    if @indicator.try(:activate)
      redirect_to indicators_path
    end
  end

  def destroy
    @indicator.destroy
    redirect_to indicators_path
  end

  private

    def indicator_filters
      params.permit(:active)
    end

    def set_current_user
      @user = current_user
    end

    def set_indicator
      @indicator = Indicator.find(params[:id])
    end

    def set_selection
      @indicator_relation_types = RelationType.order(:title).includes_act_indicator_relations.collect { |rt| [ rt.title, rt.id ] }
      @categories = SocioCulturalDomain.order(:name)
      @units = Unit.order(:name)
      @acts_to_select = Act.order(:name).filter_actives
    end

    def set_memberships
      @actions = @indicator.acts.filter_actives
    end

    def update_indicator_flow
      redirect_to indicator_path(@indicator)
    end

    def indicator_params
      params.require(:indicator).permit!
    end

    def menu_highlight
      @menu_highlighted = :indicators
    end
end
