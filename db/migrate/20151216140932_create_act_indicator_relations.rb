class CreateActIndicatorRelations < ActiveRecord::Migration
  def change
    create_table :act_indicator_relations do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.integer :act_id, index: true
      t.integer :indicator_id, index: true
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :deadline
      t.decimal :target_value

      t.timestamps null: false
    end
    add_index :act_indicator_relations, [:act_id, :indicator_id], name: 'index_act_indicator', unique: true
  end
end
