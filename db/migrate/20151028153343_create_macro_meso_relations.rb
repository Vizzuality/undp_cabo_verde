class CreateMacroMesoRelations < ActiveRecord::Migration
  def change
    create_table :macro_meso_relations do |t|
      t.integer :macro_id, index: true
      t.integer :meso_id, index: true

      t.timestamps null: false
    end
  end
end
