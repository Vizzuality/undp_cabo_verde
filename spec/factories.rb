FactoryGirl.define do

  sequence(:email) { |n| "person-#{n}@example.com" }

  # Users #
  factory :user, class: User do
    firstname 'Pepe'
    lastname 'Moreno'
    email
    password  'password'
    password_confirmation {|u| u.password}
  end

end