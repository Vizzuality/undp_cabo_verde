class CreateActors < ActiveRecord::Migration
  def change
    create_table :actors do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :type, null: false, index: true
      t.string :name, null: false
      t.boolean :active, default: true, null: false
      t.datetime :deactivated_at
      t.text :observation
      t.integer :gender, default: 1, comment: 'Gender for ActorMicro'
      t.integer :operational_filed, default: 1, comment: 'Category: Global / International / National'
      t.integer :title, default: 1, comment: 'Mr, Ms, Mrs, etc...'
      t.datetime :date_of_birth
      t.timestamps null: false
    end
  end
end
