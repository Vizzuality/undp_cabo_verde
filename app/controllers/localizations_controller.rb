class LocalizationsController < ApplicationController
  load_and_authorize_resource
  
  before_action :authenticate_user!
  before_action :set_localization, except: [:new, :create]

  def edit
  end

  def new
    @localization = owner.localizations.new
  end

  def create
    @localization = owner.localizations.create!(localization_params)
    if @localization.save
      @localization.update(user_id: @user.id) and redirect_to redirect_paths
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

  def deactivate
    if @localization.try(:deactivate)
      redirect_to redirect_paths
    end
  end

  def activate
    if @localization.try(:activate)
      redirect_to redirect_paths
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
      @user = if params[:actor_id] && Actor.find(params[:actor_id]).user
                Actor.find(params[:actor_id]).user
              else
                current_user
              end
      # ToDo: Setup owners for artefacts and actions
      @owner = if params[:actor_id]
                 @user.actors.find(params[:actor_id])
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
