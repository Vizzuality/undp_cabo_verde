class UsersController < ApplicationController

  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_current_user, only: :dashboard
  before_action :set_user, only: [:show, :activate, :deactivate]

  def index
    if params[:active].present? && params[:active]['false'].present?
      @users = User.filter_inactives
    else
      @users = User.filter_actives
    end
  end

  def show
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

  private
    def set_current_user
      @user = current_user
    end

    def set_user
      @user = User.find(params[:id])
    end

    def menu_highlight
      @menu_highlighted = :users
    end

end


