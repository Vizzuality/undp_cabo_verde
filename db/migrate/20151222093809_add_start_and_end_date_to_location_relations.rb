class AddStartAndEndDateToLocationRelations < ActiveRecord::Migration
  def change
    add_column :actor_localizations, :start_date, :datetime
    add_column :act_localizations, :start_date, :datetime
    add_column :indicator_localizations, :start_date, :datetime
    add_column :actor_localizations, :end_date, :datetime
    add_column :act_localizations, :end_date, :datetime
    add_column :indicator_localizations, :end_date, :datetime
  end
end
