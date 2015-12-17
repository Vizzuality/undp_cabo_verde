class CreateIndicatorLocalizations < ActiveRecord::Migration
  def change
    create_table :indicator_localizations do |t|
      t.integer :localization_id, index: true
      t.integer :indicator_id, index: true

      t.timestamps null: false
    end
  end
end
