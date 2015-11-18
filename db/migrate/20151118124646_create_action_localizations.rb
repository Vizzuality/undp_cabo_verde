class CreateActionLocalizations < ActiveRecord::Migration
  def change
    create_table :action_localizations do |t|
      t.integer :localization_id, index: true
      t.integer :action_id, index: true

      t.timestamps null: false
    end
  end
end
