class CreateActionRelations < ActiveRecord::Migration
  def change
    create_table :action_relations do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.integer :parent_id, comment: 'ID parent', index: true
      t.integer :child_id, comment: 'ID child', index: true
      t.datetime :start_date
      t.datetime :end_date
      t.string :title
      t.string :title_reverse

      t.timestamps null: false
    end
    add_index :action_relations, [:parent_id, :child_id], name: 'index_action_parent_child', unique: true
    rename_index :actor_relations, 'index_parent_child', 'index_actor_parent_child'
  end
end
