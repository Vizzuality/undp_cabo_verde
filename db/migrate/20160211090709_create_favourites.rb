class CreateFavourites < ActiveRecord::Migration
  def change
    create_table :favourites do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.integer :favorable_id
      t.string  :favorable_type
      t.string  :uri, null: false
      t.string  :name
      t.integer :position, default: 0

      t.timestamps null: false
    end
    add_index :favourites, [:user_id, :favorable_id, :favorable_type], unique: true
  end
end
