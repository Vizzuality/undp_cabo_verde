module LocalizationsHelper
  def polymorphic_localization_path(owner, localization)
    if owner.class.name.include?('Actor')
      actor_localization_path(actor_id: owner.id, id: localization)
    else
      act_localization_path(act_id: owner.id, id: localization)
    end
  end

  def polymorphic_create_localization_path(owner)
    if owner.class.name.include?('Actor')
      actor_localizations_path(actor_id: owner.id)
    else
      act_localizations_path(act_id: owner.id)
    end
  end
end