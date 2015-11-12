class CategoriesController < ApplicationController
  load_and_authorize_resource
  
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_category, except: [:index, :new, :create]
  before_action :set_selection, only: [:new, :edit]
  
  def index
    @categories = Category.with_children
  end

  def show
  end

  def edit
  end

  def new
    @category = Category.new
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path
    else
      render :edit
    end
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to edit_category_path(@category)
    else
      render :new
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path
  end

  private
  
    def set_category
      @category = Category.find(params[:id])
    end

    def set_selection
      @categories = Category.all
    end

    def category_params
      params.require(:category).permit!
    end

    def menu_highlight
      @menu_highlighted = :categories
    end
end
