class CreateRelationTypes < ActiveRecord::Migration
  def change
    create_table :relation_types do |t|
      t.integer :relation_category
      t.string :title
      t.string :title_reverse

      t.timestamps null: false
    end
  end
end
