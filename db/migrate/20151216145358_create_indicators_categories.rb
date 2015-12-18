class CreateIndicatorsCategories < ActiveRecord::Migration
  def change
    create_table :categories_indicators, id: false do |t|
      t.integer :category_id
      t.integer :indicator_id
    end
  end
end
