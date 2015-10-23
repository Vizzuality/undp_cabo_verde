class CreateAdminUsers < ActiveRecord::Migration
  def change
    create_table :admin_users do |t|
      t.belongs_to :user, index: true, foreign_key: true
    end
  end
end
