# Default admin user
if AdminUser.count == 0 && !Rails.env.test?
  admin = User.create!(firstname: 'Vizzuality', email: 'admin@vizzuality.com', password: '12345678', password_confirmation: '12345678')
  admin.create_admin_user
end