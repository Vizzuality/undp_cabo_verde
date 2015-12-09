module LocalizationsHelper
  def polymorphic_localization_path(owner, localization)
    # ToDo: Setup owners for artefacts and acts
    if owner.class.name.include?('Actor')
      actor_localization_path(actor_id: owner, id: localization)
    else
      act_localization_path(act_id: owner, id: localization)
    end
  end

  def polymorphic_create_localization_path(owner)
    # ToDo: Setup owners for artefacts and acts
    if owner.class.name.include?('Actor')
      actor_localizations_path(actor_id: owner)
    else
      act_localizations_path(act_id: owner)
    end
  end

  def add_fields_link(name, f, association)
    new_object = f.object.send(association).klass.new
    id         = new_object.object_id

    fields = f.fields_for(association, new_object, child_index: id) do |localizations_form|
      render(association.to_s.singularize + '_fields', f: localizations_form)
    end

    link_to(name, '', class: 'add_fields', data: { id: id, fields: fields.gsub("\n", '')})
  end
end