class RelationTypesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_relation_type, only: [:edit, :update, :destroy]
  before_action :set_selection, except: [:index, :destroy]

  def index
    @relation_types = RelationType.all
  end

  def edit
  end

  def new
    @relation_type = RelationType.new
  end

  def update
    if @relation_type.update(relation_type_params)
      redirect_to relation_types_path
    else
      render :edit
    end
  end

  def create
    @relation_type = RelationType.new(relation_type_params)
    if @relation_type.save
      redirect_to relation_types_path
    else
      render :new
    end
  end

  def destroy
    @relation_type.destroy
    redirect_to relation_types_path
  end

  private

    def set_relation_type
      @relation_type = RelationType.find(params[:id])
    end

    def set_selection
      @relation_categories = RelationType.relation_categories.map.with_index(1).to_a
    end

    def relation_type_params
      params.require(:relation_type).permit!
    end

    def menu_highlight
      @menu_highlighted = :relation_types
    end
end
