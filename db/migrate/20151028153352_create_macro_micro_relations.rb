class CreateMacroMicroRelations < ActiveRecord::Migration
  def change
    create_table :macro_micro_relations do |t|
      t.integer :macro_id, index: true
      t.integer :micro_id, index: true

      t.timestamps null: false
    end
  end
end
