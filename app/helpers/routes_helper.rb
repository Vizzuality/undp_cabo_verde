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
    elsif commentable.class.name.include?('Indicator')
      indicator_comments_path(commentable)
    else
      act_comments_path(commentable)
    end
  end

  def activate_comment_path(commentable, comment)
    if commentable.class.name.include?('Actor')
      activate_actor_comment_path(commentable, comment)
    elsif commentable.class.name.include?('Indicator')
      activate_indicator_comment_path(commentable, comment)
    else
      activate_act_comment_path(commentable, comment)
    end
  end

  def deactivate_comment_path(commentable, comment)
    if commentable.class.name.include?('Actor')
      deactivate_actor_comment_path(commentable, comment)
    elsif commentable.class.name.include?('Indicator')
      deactivate_indicator_comment_path(commentable, comment)
    else
      deactivate_act_comment_path(commentable, comment)
    end
  end

  def add_location_path(name, f, association, class_name=nil)
    form_name = 'localizations/form'
    common_nested_path(form_name, name, f, association, class_name)
  end

  def add_action_relation_path(name, f, association, class_name=nil)
    form_name = 'action_relation_form'
    common_nested_path(form_name, name, f, association, class_name)
  end

  def add_action_relation_children_path(name, f, association, class_name=nil)
    form_name = 'action_relation_children_form'
    common_nested_path(form_name, name, f, association, class_name)
  end

  def add_actor_relation_path(name, f, association, class_name=nil)
    form_name = 'actor_relation_form'
    common_nested_path(form_name, name, f, association, class_name)
  end

  def add_actor_relation_children_path(name, f, association, class_name=nil)
    form_name = 'actor_relation_children_form'
    common_nested_path(form_name, name, f, association, class_name)
  end

  def add_indicator_relation_path(name, f, association, class_name=nil)
    form_name = 'indicator_relation_form'
    common_nested_path(form_name, name, f, association, class_name)
  end

  def add_act_indicator_relation_path(name, f, association, class_name=nil)
    form_name = 'action_relation_form'
    common_nested_path(form_name, name, f, association, class_name)
  end

  def add_measurement_path(name, f, association, class_name=nil)
    form_name = 'measurements_form'
    common_nested_path(form_name, name, f, association, class_name)
  end

  def add_other_domain_path(name, f, association, class_name=nil)
    form_name = 'categories/other_domain_form'
    common_nested_path(form_name, name, f, association, class_name)
  end

  def common_form?
    request_path  = (request.path.include?('/edit') || request.path.include?('/new'))
    action_method = controller.action_name.include?('create') || controller.action_name.include?('update')
    request_path || action_method ? false : true
  end

  def common_nested_path(form_name, name, f, association, class_name=nil)
    new_object = f.object.send(association).klass.new
    id         = new_object.object_id

    fields = f.fields_for(association, new_object, child_index: id) do |actions_form|
      render(form_name, f: actions_form)
    end
    link_to(name, '', class: class_name, data: { id: id, fields: fields.gsub("\n", '')})
  end
end
