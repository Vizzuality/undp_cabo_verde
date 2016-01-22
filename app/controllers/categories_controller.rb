class CategoriesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_type
  before_action :set_category, except: [:index, :new, :create]
  before_action :set_selection, only: [:new, :edit, :show]

  def index
    @ot  = OrganizationType.with_children.order(:name)
    @od  = OtherDomain.with_children.order(:name)
    @scd = SocioCulturalDomain.with_children.order(:name)
    @of  = OperationalField.with_children.order(:name)
  end

  def show
  end

  def edit
  end

  def new
    @category = type_class.new
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path
    else
      render :edit
    end
  end

  def create
    @category = type_class.new(category_params)
    if @category.save
      redirect_to categories_path
    else
      render :new
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path
  end

  private

    def set_type
      @type = type
    end

    def type
      Category.types.include?(params[:type]) ? params[:type] : 'Category'
    end

    def type_class
      type.constantize
    end

    def set_category
      @category = type_class.find(params[:id])
    end

    def set_selection
      @types      = type_class.types.map { |t| [t("types.#{t.constantize}", default: t.constantize), t.camelize] }
      @categories = Category.all
    end

    def category_params
      params.require(type.underscore.to_sym).permit!
    end

    def menu_highlight
      @menu_highlighted = :categories
    end
end
