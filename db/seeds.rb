# Default admin user
if AdminUser.count == 0 && !Rails.env.test?
  admin = User.create!(firstname: 'Admin', lastname: 'One', institution: 'Vizzuality', email: 'admin@vizzuality.com', password: '12345678', password_confirmation: '12345678')
  admin.create_admin_user
end

puts ''
puts '****************************************************************************'
puts '*                                                                          *'
puts '* Admin user created (user: "admin@vizzuality.com", password: "12345678")  *'
puts '*                                                                          *'
puts '****************************************************************************'