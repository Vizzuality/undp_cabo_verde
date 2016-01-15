class ActorRelationsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_edit_relation, only: :edit
  before_action :set_update_relation, only: :update
  before_action :set_selection, only: [:edit, :update]

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
      @actor_relation = ActorRelation.find_by(child_id: params[:actor_id],
                                              parent_id: params[:parent_id])
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

    def set_selection
      @relation_types = RelationType.includes_actor_relations.collect { |rt| [ "#{rt.relation_categories} (relational namespaces: #{rt.title_reverse} - #{rt.title})", rt.id ] }
    end
end
