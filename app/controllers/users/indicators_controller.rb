class Users::IndicatorsController < ApplicationController
  before_action :authenticate_user!

  def index
    @indicators = current_user.indicators.page params[:page]
  end
end
