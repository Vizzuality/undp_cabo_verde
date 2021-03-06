FactoryGirl.define do

  sequence(:id)       { |n| "#{n+2}" }
  sequence(:user_id)  { |n| "#{n+2}" }
  sequence(:email)    { |n| "person-#{n}@example.com" }
  sequence(:name)     { Faker::Name.name }
  sequence(:country)  { 'CV' }
  sequence(:city)     { Faker::Address.city }
  sequence(:zip_code) { Faker::Address.zip_code }
  sequence(:state)    { Faker::Address.state }
  sequence(:street)   { Faker::Address.street_address }
  sequence(:district) { Faker::Name.name }
  sequence(:web_url)  { Faker::Internet.url }
  sequence(:lat)      { Faker::Address.latitude }
  sequence(:long)     { Faker::Address.longitude }
  sequence(:uri)      { Faker::Internet.url }

  sequence(:operational_field) { create(:operational_field).id }

  # Users #
  factory :random_public_user, class: User do
    id
    email
    firstname 'Random Guest'
    lastname 'User'
    password  'password'
    password_confirmation {|u| u.password}
  end

  factory :random_user, class: User do
    id
    email
    firstname 'Random'
    lastname 'User'
    password  'password'
    password_confirmation {|u| u.password}
    after(:create) do |random_user|
      FactoryGirl.create(:manager_user, user: random_user)
    end
  end

  factory :user, class: User do
    id
    firstname 'Pepe'
    lastname  'Moreno'
    email     'pepe-moreno@sample.com'
    password  'password'
    password_confirmation { |u| u.password }
    after(:create) do |user|
      FactoryGirl.create(:manager_user, user: user)
    end
  end

  factory :manager_user do
    user_id
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
    socio_cultural_domains { [FactoryGirl.create(:socio_cultural_domain, name: "Family, #{ Faker::Commerce.department(5, true) }")] }
  end

  factory :actor_micro, class: ActorMicro do
    name 'Person one'
    type 'ActorMicro'
    observation 'Lorem ipsum...'
    socio_cultural_domains { [FactoryGirl.create(:socio_cultural_domain, name: "Education, #{ Faker::Commerce.department(5, true) }")] }
  end

  factory :actor_meso, class: ActorMeso do
    name 'Department one'
    type 'ActorMeso'
    observation 'Lorem ipsum...'
    socio_cultural_domains { [FactoryGirl.create(:socio_cultural_domain, name: "Economy, #{ Faker::Commerce.department(5, true) }")] }
  end

  factory :actor_macro, class: ActorMacro do
    name 'Organization one'
    type 'ActorMacro'
    observation 'Lorem ipsum...'
    after(:build) { |macro| macro.update!(operational_field: create(:operational_field, name: "Global, #{ Faker::Commerce.department(5, true) }").id) }
    socio_cultural_domains { [FactoryGirl.create(:socio_cultural_domain, name: "Fishery, #{ Faker::Commerce.department(5, true) }")] }
  end

  # Acts
  factory :act_micro, class: ActMicro do
    name 'Third one'
    type 'ActMicro'
    description 'Lorem ipsum...'
    socio_cultural_domains { [FactoryGirl.create(:socio_cultural_domain, name: "Family, #{ Faker::Commerce.department(5, true) }")] }
  end

  factory :act_meso, class: ActMeso do
    name 'Second one'
    type 'ActMeso'
    description 'Lorem ipsum...'
    socio_cultural_domains { [FactoryGirl.create(:socio_cultural_domain, name: "Education, #{ Faker::Commerce.department(5, true) }")] }
  end

  factory :act_macro, class: ActMacro do
    name 'First one'
    type 'ActMacro'
    description 'Lorem ipsum...'
    socio_cultural_domains { [FactoryGirl.create(:socio_cultural_domain, name: "Economy, #{ Faker::Commerce.department(5, true) }")] }
  end

  # Localizations
  factory :localization do
    name
    country
    city
    zip_code
    state
    district
    web_url
    lat
    long
    street
  end

  # Categories
  factory :category do
    name  { "Category one, #{ Faker::Commerce.department(5, true) }" }
    type 'OtherDomain'
  end

  factory :operational_field, class: OperationalField do
    name { "Local, #{ Faker::Commerce.department(5, true) }" }
  end

  factory :socio_cultural_domain, class: SocioCulturalDomain do
    name { "Faith, #{ Faker::Commerce.department(5, true) }" }
  end

  # Comments
  factory :comment do
    body Faker::Lorem.paragraph(5, true, 4)
  end

  # Relation types
  factory :actors_relation_type, class: RelationType do
    title         'partners with'
    title_reverse 'partners with'
    relation_category 1
  end

  factory :actors_relation_type_belongs, class: RelationType do
    title         'contains'
    title_reverse 'belongs to'
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

  # Indicators
  factory :indicator, class: Indicator do
    name             'Indicator one'
    alternative_name 'Indicator one alternative'
    description      Faker::Lorem.paragraph(5, true, 4)
  end

  factory :act_indicator_relation, class: ActIndicatorRelation do
    start_date   { Time.zone.now }
    end_date     { 5.days.from_now }
    deadline     { 7.days.from_now }
    target_value '100.001'
  end

  factory :unit, class: Unit do
    name   'Euro'
    symbol '€'
  end

  factory :measurement, class: Measurement do
    date    Time.zone.now
    value   '100.001'
    details Faker::Lorem.paragraph(5, true, 4)
  end

  factory :act_indicator_relation_type_belongs, class: RelationType do
    title         'contains'
    title_reverse 'belongs to'
    relation_category 5
  end

  factory :favourite do
    name
    uri
  end
end
