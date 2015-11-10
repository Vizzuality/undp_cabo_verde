class ActorRelationsController < ApplicationController
  load_and_authorize_resource
  before_action :set_edit_relation, only: :edit
  before_action :set_update_relation, only: :update

  def edit
  end

  def update
    if @actor_relation.update(actor_relation_params)
      redirect_to membership_actor_path(@actor_relation.child_id)
    else
      render :edit
    end
  end

  private
  
    def set_edit_relation
      @actor_relation = ActorRelation.find_by(child_id: params[:actor_id], parent_id: params[:parent_id])
    end

    def set_update_relation
      @actor_relation = ActorRelation.find(params[:relation_id])
    end

    def actor_relation_params
      params.require(:actor_relation).permit!
    end

    def menu_highlight
      @menu_highlighted = :actors
    end
end
