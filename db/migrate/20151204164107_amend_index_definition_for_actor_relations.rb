class AmendIndexDefinitionForActorRelations < ActiveRecord::Migration
  def change
    remove_index :actor_relations, name: :index_actor_parent_child
    add_index :actor_relations, [:parent_id, :child_id, :relation_type_id], name: 'index_parent_child_relation_type', unique: true
  end
end
