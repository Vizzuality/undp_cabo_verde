class CreateActorMesoMacro < ActiveRecord::Migration
  def change
    create_table :actor_meso_macros do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.integer :macro_id, index: true
      t.integer :meso_id, index: true

      t.timestamps null: false
    end
  end
end
