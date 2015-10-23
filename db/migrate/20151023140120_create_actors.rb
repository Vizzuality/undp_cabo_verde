class CreateActors < ActiveRecord::Migration
  def change
    create_table :actors do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :type, null: false, index: true
      t.string :title, null: false
      t.boolean :active, default: true, null: false
      t.datetime :deactivated_at
      t.text :description
      t.text :observation
      t.text :extend_description
      t.timestamps null: false
    end
  end
end
