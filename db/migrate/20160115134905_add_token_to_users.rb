class AddTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :authentication_token, :string
    add_column :users, :token_expires_at, :datetime

    add_index :users, :authentication_token, unique: true
  end
end
