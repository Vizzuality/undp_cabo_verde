class ActRelationsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  
  before_action :set_edit_relation, only: :edit
  before_action :set_update_relation, only: :update
  before_action :set_selection, only: [:edit, :update]

  def edit
  end

  def update
    if @act_relation.update(act_relation_params)
      redirect_to membership_act_path(@act_relation.child_id)
    else
      render :edit
    end
  end

  private
  
    def set_edit_relation
      @act_relation = ActRelation.find_by(child_id: params[:act_id], 
                                              parent_id: params[:parent_id])
    end

    def set_update_relation
      @act_relation = ActRelation.find(params[:relation_id])
    end

    def act_relation_params
      params.require(:act_relation).permit!
    end

    def menu_highlight
      @menu_highlighted = :acts
    end

    def set_selection
      @relation_types = RelationType.includes_act_relations.collect { |rt| [ "#{rt.relation_categories} (relational namespaces: #{rt.title_reverse} - #{rt.title})", rt.id ] }
    end
end
