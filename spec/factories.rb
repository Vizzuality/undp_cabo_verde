FactoryGirl.define do

  sequence(:id)       { |n| "#{n+2}" }
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

  sequence(:operational_field) { create(:operational_field).id }

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
    merged_domains { [FactoryGirl.create(:socio_cultural_domain, name: "Faith_#{rand(1001..2000).to_s}")] }
  end

  factory :actor_micro, class: ActorMicro do
    name 'Person one'
    type 'ActorMicro'
    observation 'Lorem ipsum...'
    merged_domains { [FactoryGirl.create(:socio_cultural_domain, name: "Faith_#{rand(2001..3000).to_s}")] }
  end

  factory :actor_meso, class: ActorMeso do
    name 'Department one'
    type 'ActorMeso'
    observation 'Lorem ipsum...'
    merged_domains { [FactoryGirl.create(:socio_cultural_domain, name: "Faith_#{rand(3001..4000).to_s}")] }
  end

  factory :actor_macro, class: ActorMacro do
    name 'Organization one'
    type 'ActorMacro'
    observation 'Lorem ipsum...'
    after(:build) { |macro| macro.update!(operational_field: create(:operational_field, name: "Global_#{rand(1001..2000).to_s}").id) }
    merged_domains { [FactoryGirl.create(:socio_cultural_domain, name: "Faith_#{rand(4001..5000).to_s}")] }
  end

  # Acts
  factory :act_micro, class: ActMicro do
    name 'Third one'
    type 'ActMicro'
    description 'Lorem ipsum...'
    merged_domains { [FactoryGirl.create(:socio_cultural_domain, name: "Faith_#{rand(5001..6000).to_s}")] }
  end

  factory :act_meso, class: ActMeso do
    name 'Second one'
    type 'ActMeso'
    description 'Lorem ipsum...'
    merged_domains { [FactoryGirl.create(:socio_cultural_domain, name: "Faith_#{rand(6001..7000).to_s}")] }
  end

  factory :act_macro, class: ActMacro do
    name 'First one'
    type 'ActMacro'
    description 'Lorem ipsum...'
    merged_domains { [FactoryGirl.create(:socio_cultural_domain, name: "Faith_#{rand(7001..8000).to_s}")] }
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
    name  { "Category one_#{rand(1000).to_s}" }
    type 'OtherDomain'
  end

  factory :operational_field, class: OperationalField do
    name { "Global_#{rand(1000).to_s}" }
  end

  factory :socio_cultural_domain, class: SocioCulturalDomain do
    name { "Faith_#{rand(1000).to_s}" }
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
    description      Faker::Lorem.paragraph(2, true, 4)
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
    details Faker::Lorem.paragraph(2, true, 4)
  end

  factory :act_indicator_relation_type_belongs, class: RelationType do
    title         'contains'
    title_reverse 'belongs to'
    relation_category 5
  end
end
