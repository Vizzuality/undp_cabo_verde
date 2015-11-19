class CreateActLocalizations < ActiveRecord::Migration
  def change
    create_table :act_localizations do |t|
      t.integer :localization_id, index: true
      t.integer :act_id, index: true

      t.timestamps null: false
    end
  end
end
