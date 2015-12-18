class UnitsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_unit, only: [:edit, :update, :destroy]

  def index
    @units = Unit.order(:name)
  end

  def edit
  end

  def new
    @unit = Unit.new
  end

  def update
    if @unit.update(unit_params)
      redirect_to units_path
    else
      render :edit
    end
  end

  def create
    @unit = Unit.new(unit_params)
    if @unit.save
      redirect_to units_path
    else
      render :new
    end
  end

  def destroy
    @unit.destroy
    redirect_to units_path
  end

  private

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
