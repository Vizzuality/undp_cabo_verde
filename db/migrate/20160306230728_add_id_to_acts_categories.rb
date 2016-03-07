class AddIdToActsCategories < ActiveRecord::Migration
  def change
    add_column :acts_categories, :id, :primary_key
  end
end
