module ActorsHelper
  def link_actor(actor, parent)
    link_actor_actor_path(actor, parent_id: parent.id)
  end

  def unlink_actor(actor, parent)
    unlink_actor_actor_path(actor, parent_id: parent.id)
  end

  def edit_relation(actor, parent)
    actor_edit_actor_relation_path(actor, parent)
  end
end
