class AddFieldsToActors < ActiveRecord::Migration
  def change
    add_column :actors, :short_name, :string
    add_column :actors, :legal_status, :string
    add_column :actors, :other_names, :string
  end
end
