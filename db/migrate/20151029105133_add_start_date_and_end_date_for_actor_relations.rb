class AddStartDateAndEndDateForActorRelations < ActiveRecord::Migration
  def change
    add_column :actor_micro_mesos, :meso_start_date, :datetime
    add_column :actor_micro_mesos, :meso_end_date, :datetime

    add_column :actor_micro_macros, :macro_start_date, :datetime
    add_column :actor_micro_macros, :macro_end_date, :datetime

    add_column :actor_meso_macros, :macro_start_date, :datetime
    add_column :actor_meso_macros, :macro_end_date, :datetime
  end
end
