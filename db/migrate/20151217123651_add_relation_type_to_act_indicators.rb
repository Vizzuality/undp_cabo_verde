class AddRelationTypeToActIndicators < ActiveRecord::Migration
  def change
    add_column :act_indicator_relations, :relation_type_id, :integer
  end
end
