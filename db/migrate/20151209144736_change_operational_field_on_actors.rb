class ChangeOperationalFieldOnActors < ActiveRecord::Migration
  def change
    change_column_default(:actors, :operational_field, nil)
  end
end
