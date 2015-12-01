FactoryGirl.define do
  
  sequence(:id) { |n| "#{n+2}" }
  sequence(:email) { |n| "person-#{n}@example.com" }
  sequence(:name) { Faker::Name.name }
  sequence(:country) { Faker::Address.country }
  sequence(:city) { Faker::Address.city }
  sequence(:zip_code) { Faker::Address.zip_code }
  sequence(:state) { Faker::Address.state }
  sequence(:district) { Faker::Name.name }
  sequence(:lat) { Faker::Address.latitude }
  sequence(:long) { Faker::Address.longitude }

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
    password_confirmation { |u| u.password }
  end
  
  # Admin users
  factory :adminuser, class: User do
    id 1
    firstname 'Juanito'
    lastname  'Lolito'
    email     'admin@sample.com'
    password  'password'
    password_confirmation { |u| u.password }
  end

  factory :admin, class: AdminUser do
    user_id 1
  end

  factory :random_adminuser, class: User do
    id 2
    email
    password  'password'
    password_confirmation { |u| u.password }
  end

  factory :admin_2, class: AdminUser do
    user_id 2
  end
  
  # Actors
  factory :person_actor, class: ActorMicro do
    name 'Person two'
    type 'ActorMicro'
    observation 'Lorem ipsum...'
  end

  factory :actor_micro, class: ActorMicro do
    name 'Person one'
    type 'ActorMicro'
    observation 'Lorem ipsum...'
  end

  factory :actor_meso, class: ActorMeso do
    name 'Department one'
    type 'ActorMeso'
    observation 'Lorem ipsum...'
  end

  factory :actor_macro, class: ActorMacro do
    name 'Organization one'
    type 'ActorMacro'
    observation 'Lorem ipsum...'
  end

  # Acts
  factory :act_micro, class: ActMicro do
    name 'Third one'
    type 'ActMicro'
    description 'Lorem ipsum...'
  end

  factory :act_meso, class: ActMeso do
    name 'Second one'
    type 'ActMeso'
    description 'Lorem ipsum...'
  end

  factory :act_macro, class: ActMacro do
    name 'First one'
    type 'ActMacro'
    description 'Lorem ipsum...'
  end

  # Localizations
  factory :localization do
    name
    country
    city
    zip_code
    state
    district
    lat
    long
  end
  
  # Categories
  factory :category do
    name 'Category one'
    type 'OtherDomain'
  end
  
  # Comments
  factory :comment do
    body Faker::Lorem.paragraph(2, true, 4)
  end

  # Relation types
  factory :actors_relation_type, class: RelationType do
    title         'partners with'
    title_reverse 'partners with'
    relation_category 1
  end

  factory :act_actor_relation_type, class: RelationType do
    title         'implements'
    title_reverse 'implemented by'
    relation_category 3
  end

  factory :acts_relation_type, class: RelationType do
    title         'contains'
    title_reverse 'belongs to'
    relation_category 7
  end

end