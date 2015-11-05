module ApplicationHelper
  def menu_highlight?(page_identifier)
    page_identifier == @menu_highlighted
  end

  def polymorphic_localization_path(owner, localization)
    # ToDo: Setup owners for artefacts and actions
    if owner.class.name.include?('Actor')
      actor_localization_path(actor_id: owner, id: localization)
    end
  end

  def polymorphic_create_localization_path(owner)
    # ToDo: Setup owners for artefacts and actions
    if owner.class.name.include?('Actor')
      actor_localizations_path(actor_id: owner)
    end
  end
end
