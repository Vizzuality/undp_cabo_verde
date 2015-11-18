class CreateActionActorRelations < ActiveRecord::Migration
  def change
    create_table :action_actor_relations do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.integer :action_id, index: true
      t.integer :actor_id, index: true
      t.datetime :start_date
      t.datetime :end_date
      t.string :title
      t.string :title_reverse

      t.timestamps null: false
    end
    add_index :action_actor_relations, [:action_id, :actor_id], name: 'index_action_actor', unique: true
  end
end
