class CreateActs < ActiveRecord::Migration
  def change
    create_table :acts do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :type, null: false, index: true
      t.string :name, null: false
      t.string :alternative_name
      t.string :short_name
      t.boolean :event, default: false
      t.boolean :human, default: false
      t.boolean :active, default: true, null: false
      t.datetime :deactivated_at
      t.text :description
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps null: false
    end
  end
end
