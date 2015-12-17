class CreateIndicators < ActiveRecord::Migration
  def change
    create_table :indicators do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :name, null: false
      t.string :alternative_name
      t.boolean :active, default: true, null: false
      t.datetime :deactivated_at
      t.text :description

      t.timestamps null: false
    end
  end
end
