module ActorsHelper

  def sti_link_macro(actor, macro_id)
    if actor.type == 'ActorMeso'
      link_macro_actor_meso_path(actor, macro_id: macro_id)
    else
      link_macro_actor_micro_path(actor, macro_id: macro_id)
    end
  end

  def sti_link_meso(actor, meso_id)
    link_meso_actor_micro_path(actor, meso_id: meso_id)
  end

  def sti_unlink_macro(actor, macro_id)
    if actor.type == 'ActorMeso'
      unlink_macro_actor_meso_path(actor, relation_id: macro_id)
    else
      unlink_macro_actor_micro_path(actor, relation_id: macro_id)
    end
  end

  def sti_unlink_meso(actor, meso_id)
    unlink_meso_actor_micro_path(actor, relation_id: meso_id)
  end
end
