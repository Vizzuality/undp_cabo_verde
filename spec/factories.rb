FactoryGirl.define do
  
  sequence(:id) { |n| "#{n+1}" }
  sequence(:email) { |n| "person-#{n}@example.com" }

  # Users #
  factory :random_user, class: User do
    id
    email
    password  'password'
    password_confirmation {|u| u.password}
  end

  factory :user, class: User do
    id
    firstname 'Pepe'
    lastname  'Moreno'
    email     'pepe-moreno@sample.com'
    password  'password'
    password_confirmation {|u| u.password}
  end

  factory :adminuser, class: User do
    id 1
    firstname 'Juanito'
    lastname  'Lolito'
    email     'admin@sample.com'
    password  'password'
    password_confirmation {|u| u.password}
  end

  factory :admin, class: AdminUser do
    user_id 1
  end

end