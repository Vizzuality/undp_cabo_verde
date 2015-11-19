module RoutesHelper
  def link_act(act, parent)
    link_act_act_path(act, parent_id: parent.id)
  end

  def unlink_act(act, parent)
    unlink_act_act_path(act, parent_id: parent.id)
  end

  def link_actor(actor, parent)
    link_actor_actor_path(actor, parent_id: parent.id)
  end

  def unlink_actor(actor, parent)
    unlink_actor_actor_path(actor, parent_id: parent.id)
  end

  def edit_relation(owner, parent)
    if owner.class.name.include?('Actor')
      actor_edit_actor_relation_path(owner, parent)
    else
      act_edit_act_relation_path(owner, parent)
    end
  end
end
