class AddUserToUnits < ActiveRecord::Migration
  def change
    add_reference :units, :user, index: true, foreign_key: true

    if AdminUser.any? && Unit.any? && !Rails.env.test?
      @user = User.find_by(email: 'admin@vizzuality.com')
      Unit.update_all(user_id: @user.id)
    end
  end
end
