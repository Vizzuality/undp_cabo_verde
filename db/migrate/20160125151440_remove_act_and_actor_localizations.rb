class RemoveActAndActorLocalizations < ActiveRecord::Migration
  def change
    if Localization.table_name == 'locations'
      # Drop unused tables
      drop_table :act_localizations   if ActiveRecord::Base.connection.table_exists? 'act_localizations'
      drop_table :actor_localizations if ActiveRecord::Base.connection.table_exists? 'actor_localizations'
    end
  end
end
