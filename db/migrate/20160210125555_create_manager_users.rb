class CreateManagerUsers < ActiveRecord::Migration
  def up
    create_table :manager_users do |t|
      t.belongs_to :user, index: true, foreign_key: true
    end

    unless Rails.env.test?
      if ActiveRecord::Base.connection.table_exists? 'manager_users'
        User.not_admin_users.each do |user|
          user.make_manager
        end
      end
    end
  end

  def down
  	drop_table :manager_users
  end
end
