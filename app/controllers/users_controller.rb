class UsersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_current_user, only: :dashboard
  before_action :set_user, except: [:index, :dashboard]
  before_action :user_filters, only: :index

  def index
    @users = if current_user && current_user.admin?
               User.filter_users(user_filters).page params[:page]
             else
               User.filter_actives.page params[:page]
             end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to user_path, notice: 'User updated'
    else
      render :edit
    end
  end

  def dashboard
    @menu_highlighted = :home
  end

  def deactivate
    if @user.try(:deactivate)
      redirect_to users_path
    else
      redirect_to user_path(@user)
    end
  end

  def activate
    if @user.try(:activate)
      redirect_to users_path
    else
      redirect_to user_path(@user)
    end
  end

  def make_admin
    if @user.try(:make_admin)
      redirect_to users_path
    end
  end

  def make_manager
    if @user.try(:make_manager)
      redirect_to users_path
    end
  end

  def make_user
    if @user.try(:make_user)
      redirect_to users_path
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  private

    def user_filters
      params.permit(:active)
    end

    def set_current_user
      @user = current_user
    end

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit!
    end

    def menu_highlight
      @menu_highlighted = :users
    end
end


