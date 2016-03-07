class AddIdToCategoriesIndicators < ActiveRecord::Migration
  def change
    add_column :categories_indicators, :id, :primary_key
  end
end
