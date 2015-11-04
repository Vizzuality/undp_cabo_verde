class CreateActorMicroMeso < ActiveRecord::Migration
  def change
    create_table :actor_micro_mesos do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.integer :meso_id, index: true
      t.integer :micro_id, index: true

      t.timestamps null: false
    end
  end
end
