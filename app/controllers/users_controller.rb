class UsersController < ApplicationController

  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_current_user, only: :dashboard
  before_action :set_user, except: [:index, :dashboard]
  before_action :user_filters, only: :index

  load_and_authorize_resource
  
  def index
    @users = if current_user && current_user.admin?
               User.filter_users(user_filters)
             else
               User.filter_actives
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
      @user.errors.messages.not_saved
      render :edit
    end
  end

  def dashboard
    @menu_highlighted = :home
  end

  def deactivate
    if @user.try(:deactivate)
      redirect_to users_path
    end
  end

  def activate
    if @user.try(:activate)
      redirect_to users_path
    end
  end

  def make_admin
    if @user.try(:make_admin)
      redirect_to users_path
    end
  end

  def make_user
    if @user.try(:make_user)
      redirect_to users_path
    end
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


