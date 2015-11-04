class ActorMesoMacrosController < ApplicationController
  load_and_authorize_resource
  before_action :set_relation

  def edit
  end

  def update
    if @actor_relation.update(actor_relation_params)
      redirect_to membership_actor_meso_path(@actor_relation.meso_id)
    else
      render :edit
    end
  end

  private
  
    def set_relation
      @actor_relation = ActorMesoMacro.find(params[:relation_id])
    end

    def actor_relation_params
      params.require(:actor_meso_macro).permit!
    end

    def menu_highlight
      @menu_highlighted = :actors
    end
end
