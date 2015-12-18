class RemoveDateOfBirthFromActors < ActiveRecord::Migration
  def change
    remove_column :actors, :date_of_birth, :datetime
  end
end
