if AdminUser.count == 0 && !Rails.env.test?
  User.seed(:id,
    {id: 1, email: 'admin@vizzuality.com', password: '12345678', password_confirmation: '12345678', firstname: 'Admin', lastname: 'One', institution: 'Vizzuality'}
  )

  AdminUser.seed do |s|
    s.id      = 1
    s.user_id = 1
  end

  puts ''
  puts '****************************************************************************'
  puts '*                                                                          *'
  puts '* Admin user created (user: "admin@vizzuality.com", password: "12345678")  *'
  puts '*                                                                          *'
  puts '****************************************************************************'
end

User.seed(:id,
  {id: 2, email: 'user_one@vizzuality.com', password: 'password', password_confirmation: 'password', firstname: 'User', lastname: 'One', institution: 'Vizzuality'},
  {id: 3, email: 'user_two@vizzuality.com', password: 'password', password_confirmation: 'password', firstname: 'User', lastname: 'Two', institution: 'Vizzuality'}
)

puts ''
puts '****************************************************************************'
puts '*                                                                          *'
puts '* User created (user: "user_one@vizzuality.com", password: "password")     *'
puts '* User created (user: "user_two@vizzuality.com", password: "password")     *'
puts '*                                                                          *'
puts '****************************************************************************'