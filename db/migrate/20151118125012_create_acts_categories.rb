class CreateActsCategories < ActiveRecord::Migration
  def change
    create_table :acts_categories, id: false do |t|
      t.integer :category_id
      t.integer :act_id
    end
  end
end
