class RemoveIndicatorLocalizationsTable < ActiveRecord::Migration
  def change
    drop_table :indicator_localizations
  end
end
