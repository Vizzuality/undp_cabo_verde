class AddParentLocationToMicroActors < ActiveRecord::Migration
  def change
    add_column :actors, :parent_location_id, :integer
    add_index :actors, [:parent_location_id]
  end
end
