class CreateLocalizations < ActiveRecord::Migration
  def change
    create_table :localizations do |t|
      t.string :country
      t.string :city
      t.string :zip_code
      t.string :state
      t.string :district
      t.string :name
      t.string :lat, comment: 'latitude for localization'
      t.string :long, comment: 'longitude for localization'

      t.timestamps null: false
    end
  end
end
