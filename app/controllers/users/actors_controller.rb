class Users::ActorsController < ApplicationController
  before_action :authenticate_user!

  def index
    @actors = current_user.actors.page params[:page]
  end
end
