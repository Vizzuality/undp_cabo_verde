class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :act_indicator_relation, index: true, foreign_key: true
      t.datetime :date
      t.decimal :value
      t.text :details
      t.boolean :active, default: true, null: false
      t.datetime :deactivated_at

      t.timestamps null: false
    end
  end
end
