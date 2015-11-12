class CreateActorsCategories < ActiveRecord::Migration
  def change
    create_table :actors_categories, id: false do |t|
      t.integer :category_id
      t.integer :actor_id
    end
  end
end
