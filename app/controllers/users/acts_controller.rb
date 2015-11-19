class Users::ActsController < ApplicationController
  before_action :authenticate_user!

  def index
    @acts = current_user.acts
  end
end
