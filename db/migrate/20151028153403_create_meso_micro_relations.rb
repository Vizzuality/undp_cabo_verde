class CreateMesoMicroRelations < ActiveRecord::Migration
  def change
    create_table :meso_micro_relations do |t|
      t.integer :meso_id, index: true
      t.integer :micro_id, index: true

      t.timestamps null: false
    end
  end
end
