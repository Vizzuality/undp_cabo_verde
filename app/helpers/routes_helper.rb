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

  def new_comment(commentable)
    if commentable.class.name.include?('Actor')
      actor_comments_path(commentable)
    else
      act_comments_path(commentable)
    end
  end

  def activate_comment_path(commentable, comment)
    if commentable.class.name.include?('Actor')
      activate_actor_comment_path(commentable, comment)
    else
      activate_act_comment_path(commentable, comment)
    end
  end

  def deactivate_comment_path(commentable, comment)
    if commentable.class.name.include?('Actor')
      deactivate_actor_comment_path(commentable, comment)
    else
      deactivate_act_comment_path(commentable, comment)
    end
  end

  def add_location_path(name, f, association)
    new_object = f.object.send(association).klass.new
    id         = new_object.object_id

    fields = f.fields_for(association, new_object, child_index: id) do |localizations_form|
      render('localizations/form', f: localizations_form)
    end

    link_to(name, '', class: 'add_fields', data: { id: id, fields: fields.gsub("\n", '')})
  end
end
