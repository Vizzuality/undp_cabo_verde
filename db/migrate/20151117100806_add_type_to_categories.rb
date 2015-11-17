class AddTypeToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :type, :string, null: false, index: true
  end
end
