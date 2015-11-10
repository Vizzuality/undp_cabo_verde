module LocalizationsHelper
  def polymorphic_localization_path(owner, localization)
    # ToDo: Setup owners for artefacts and actions
    actor_localization_path(actor_id: owner, id: localization) if owner.class.name.include?('Actor')
  end

  def polymorphic_create_localization_path(owner)
    # ToDo: Setup owners for artefacts and actions
    actor_localizations_path(actor_id: owner) if owner.class.name.include?('Actor')
  end
end