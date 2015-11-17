class AddRelationNamesToActorRelations < ActiveRecord::Migration
  def change
    add_column :actor_relations, :title, :string
    add_column :actor_relations, :title_reverse, :string
  end
end
