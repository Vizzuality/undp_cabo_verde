module LocalizationsHelper
  def polymorphic_localization_path(owner, localization)
    # ToDo: Setup owners for artefacts and acts
    if owner.class.name.include?('Actor')
      actor_localization_path(actor_id: owner, id: localization)
    elsif owner.class.name.include?('Indicator')
      indicator_localizations_path(indicator_id: owner, id: localization)
    else
      act_localization_path(act_id: owner, id: localization)
    end
  end

  def polymorphic_create_localization_path(owner)
    # ToDo: Setup owners for artefacts and acts
    if owner.class.name.include?('Actor')
      actor_localizations_path(actor_id: owner)
    elsif owner.class.name.include?('Indicator')
      indicator_localizations_path(indicator_id: owner)
    else
      act_localizations_path(act_id: owner)
    end
  end

  def cape_verde
    country = ISO3166::Country['CV']
    country.translations[I18n.locale.to_s] || country.name
  end

  def relation_location_class
    if request.path.include?('/actors/')
      :actor_localizations
    elsif request.path.include?('/indicators/')
      :indicator_localizations
    else
      :act_localizations
    end
  end
end