class AddMainAddressAndStreetToLocalizations < ActiveRecord::Migration
  def change
    add_column :actor_localizations, :main, :boolean, default: false
    add_column :act_localizations, :main, :boolean, default: false
    add_column :indicator_localizations, :main, :boolean, default: false
    add_column :localizations, :street, :string
  end
end
