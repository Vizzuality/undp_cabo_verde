class RemoveAndAddColumnsToRelationsTables < ActiveRecord::Migration
  def change
    remove_column :act_actor_relations, :title
    remove_column :act_actor_relations, :title_reverse
    remove_column :act_relations, :title
    remove_column :act_relations, :title_reverse
    remove_column :actor_relations, :title
    remove_column :actor_relations, :title_reverse

    add_column :act_actor_relations, :relation_type_id, :integer
    add_column :act_relations, :relation_type_id, :integer
    add_column :actor_relations, :relation_type_id, :integer
  end
end
