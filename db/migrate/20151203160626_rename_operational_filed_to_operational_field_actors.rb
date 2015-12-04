class RenameOperationalFiledToOperationalFieldActors < ActiveRecord::Migration
  def change
    rename_column :actors, :operational_filed, :operational_field
  end
end
