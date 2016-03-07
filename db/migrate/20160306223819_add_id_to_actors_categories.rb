class AddIdToActorsCategories < ActiveRecord::Migration
  def change
    add_column :actors_categories, :id, :primary_key
  end
end
