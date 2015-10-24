FactoryGirl.define do
  
  sequence(:id) { |n| "#{n+2}" }
  sequence(:email) { |n| "person-#{n}@example.com" }

  # Users #
  factory :random_user, class: User do
    id
    email
    firstname 'Random'
    lastname 'User'
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
  
  # Admin users
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

  factory :random_adminuser, class: User do
    id 2
    email
    password  'password'
    password_confirmation {|u| u.password}
  end

  factory :admin_2, class: AdminUser do
    user_id 2
  end
  
  # Actors
  factory :person, class: Person do
    title 'Person one'
    type 'Person'
    description 'Lorem ipsum...'
    observation 'Lorem ipsum...'
  end

  factory :organization, class: Organization do
    title 'Organization one'
    type 'Organization'
    description 'Lorem ipsum...'
    observation 'Lorem ipsum...'
  end

  factory :person_actor, class: Actor do
    title 'Person two'
    type 'Person'
    description 'Lorem ipsum...'
    observation 'Lorem ipsum...'
  end

end