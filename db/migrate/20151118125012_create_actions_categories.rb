class CreateActionsCategories < ActiveRecord::Migration
  def change
    create_table :actions_categories, id: false do |t|
      t.integer :category_id
      t.integer :action_id
    end
  end
end
