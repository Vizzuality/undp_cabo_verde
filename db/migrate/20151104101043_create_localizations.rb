class CreateLocalizations < ActiveRecord::Migration
  def change
    create_table :localizations do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.boolean :active, default: true, null: false
      t.datetime :deactivated_at
      t.string :country
      t.string :city
      t.string :zip_code
      t.string :state
      t.string :district
      t.string :name
      t.string :lat, comment: 'latitude for localization'
      t.string :long, comment: 'longitude for localization'
      t.string :web_url

      t.timestamps null: false
    end
  end
end
