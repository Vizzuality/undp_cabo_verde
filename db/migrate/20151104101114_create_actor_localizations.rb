class CreateActorLocalizations < ActiveRecord::Migration
  def change
    create_table :actor_localizations do |t|
      t.integer :localization_id, index: true
      t.integer :actor_id, index: true

      t.timestamps null: false
    end
  end
end
