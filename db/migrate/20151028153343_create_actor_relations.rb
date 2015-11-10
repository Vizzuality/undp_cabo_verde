class CreateActorRelations < ActiveRecord::Migration
  def change
    create_table :actor_relations do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.integer :parent_id, comment: 'ID parent', index: true
      t.integer :child_id, comment: 'ID child', index: true
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps null: false
    end
    add_index :actor_relations, [:parent_id, :child_id], name: 'index_parent_child', unique: true
  end
end
