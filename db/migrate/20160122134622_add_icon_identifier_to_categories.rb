class AddIconIdentifierToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :icon_identifier, :string
  end
end
