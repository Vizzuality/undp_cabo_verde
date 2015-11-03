class ActorMicroMacrosController < ApplicationController
  load_and_authorize_resource
  before_filter :set_relation

  def edit
  end

  def update
    if @actor_relation.update(actor_relation_params)
      redirect_to edit_actor_path(@actor_relation.micro_id)
    else
      render :edit
    end
  end

  private
    def set_relation
      @actor_relation = ActorMicroMacro.find(params[:relation_id])
    end

    def actor_relation_params
      params.require(:actor_micro_macro).permit!
    end

    def menu_highlight
      @menu_highlighted = :actors
    end
end
