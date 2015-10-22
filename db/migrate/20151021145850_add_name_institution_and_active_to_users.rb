class AddNameInstitutionAndActiveToUsers < ActiveRecord::Migration
  def change
    add_column :users, :firstname, :string
    add_column :users, :lastname, :string
    add_column :users, :institution, :string
    add_column :users, :active, :boolean, default: true, null: false
    add_column :users, :deactivated_at, :datetime
  end
end
