class RenameLocalizationsToLocations < ActiveRecord::Migration
  def change
    rename_table :localizations, :locations
    add_column :locations, :localizable_id, :integer
    add_column :locations, :localizable_type, :string
    add_column :locations, :main, :boolean, default: false
    add_column :locations, :start_date, :datetime
    add_column :locations, :end_date, :datetime

    add_index  :locations, [:localizable_id, :localizable_type]

    unless Rails.env.test?
      if ActLocalization.any?
        ActLocalization.all.each do |location|
          Localization.find(location.localization_id).
                   update_attributes(localizable_id: location.act_id,
                                     localizable_type: 'Act',
                                     start_date: location.start_date,
                                     end_date: location.end_date,
                                     main: location.main
                                     )
        end
      end
      if ActorLocalization.any?
        ActorLocalization.all.each do |location|
          Localization.find(location.localization_id).
                   update_attributes(localizable_id: location.actor_id,
                                     localizable_type: 'Actor',
                                     start_date: location.start_date,
                                     end_date: location.end_date,
                                     main: location.main
                                     )
        end
      end

      if Localization.any?
        Localization.where(localizable_id: nil).delete_all
      end
    end
  end
end
