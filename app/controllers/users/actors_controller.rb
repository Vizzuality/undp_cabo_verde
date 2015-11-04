class Users::ActorsController < ApplicationController
  before_action :authenticate_user!

  def index
    @actors = current_user.actors
  end
end
