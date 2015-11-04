class LocalizationsController < ApplicationController
  before_action :set_localization, except: [:new, :create]

  def show
  end

  def edit
  end

  def new
    @localization = Localization.new
  end

  def create
    @localization = owner.localizations.create!(localization_params)
    if @localization.save
      redirect_to redirect_paths
    else
      render :new
    end
  end

  def update
    if @localization.update(localization_params)
      redirect_to redirect_paths
    else
      render :edit
    end
  end

  def destroy
    @localization.destroy
    redirect_to redirect_paths
  end

  private

    def set_localization
      @localization = owner.localizations.find(params[:id])
    end

    def owner
      # ToDo: Setup owners for artefacts and actions
      @owner = if params[:actor_id]
                 current_user.actors.find(params[:actor_id])
               end
    end

    def redirect_paths
      if @owner.class.name.include?('Actor')
        edit_actor_path(@owner)
      end
    end

    def localization_params
      params.require(:localization).permit!
    end
end
