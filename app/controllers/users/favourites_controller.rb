class Users::FavouritesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_user
  before_action :set_favourite,   except: :index

  def index
  	@favourites = @user.favourites.positioned.page params[:page]
  end

  def destroy
    @favourite.destroy
    render nothing: true
  end

  private

    def set_user
      @user = current_user
    end

    def set_favourite
      @favourite = @user.favourites.find(params[:id])
    end

    def redirect_paths
      user_favourites_path(@user)
    end

    def favourite_params
      params.require(:favourite).permit!
    end
end
