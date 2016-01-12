class UnitsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  
  before_action :set_current_user, only: :create
  before_action :set_unit, only: [:edit, :update, :destroy]

  respond_to :json, :html

  def index
    @units = Unit.includes(:act_indicator_relations, :measurements).order(:name)
  end

  def edit
  end

  def new
    @unit = Unit.new
  end

  def update
    respond_to do |format|
      if @unit.update(unit_params)
        format.html { redirect_to units_path  }
        format.json { respond_with_bip(@unit) }
      else
        format.html { render :edit }
        format.json { respond_with_bip(@unit) }
      end
    end
  end

  def create
    @unit = @user.units.build(unit_params)
    if @unit.save
      redirect_to units_path
    else
      render :new
    end
  end

  def destroy
    @unit.destroy if @unit.not_associated
    redirect_to units_path
  end

  private

    def set_current_user
      @user = current_user
    end

    def set_unit
      @unit = Unit.find(params[:id])
    end

    def unit_params
      params.require(:unit).permit!
    end

    def menu_highlight
      @menu_highlighted = :units
    end
end
