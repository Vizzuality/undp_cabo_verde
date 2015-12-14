Actor.seed(:id,
  # Macros
  {id: 1,  type: 'ActorMacro', user_id: 1, observation: Faker::Lorem.paragraph(2, true, 4), operational_field: 1, name: 'Economy Organization',  category_ids: [1, 2, 3]},
  {id: 2,  type: 'ActorMacro', user_id: 2, observation: Faker::Lorem.paragraph(2, true, 4), operational_field: 2, name: 'Education Institution', category_ids: [2, 3, 4]},
  {id: 3,  type: 'ActorMacro', user_id: 3, observation: Faker::Lorem.paragraph(2, true, 4), operational_field: 3, name: 'Faith Organization',    category_ids: [3, 4, 5]},
  {id: 4,  type: 'ActorMacro', user_id: 1, observation: Faker::Lorem.paragraph(2, true, 4), operational_field: 1, name: 'Family Institution',    category_ids: [4, 5, 6]},
  {id: 5,  type: 'ActorMacro', user_id: 2, observation: Faker::Lorem.paragraph(2, true, 4), operational_field: 2, name: 'Politics Institution',  category_ids: [5, 6, 7]},
  # Mesos
  {id: 6,  type: 'ActorMeso',  user_id: 3, observation: Faker::Lorem.paragraph(2, true, 4), name: 'Agriculture Department', category_ids: [6, 7, 8]},
  {id: 7,  type: 'ActorMeso',  user_id: 1, observation: Faker::Lorem.paragraph(2, true, 4), name: 'Fishery Department',     category_ids: [7, 8, 9]},
  {id: 8,  type: 'ActorMeso',  user_id: 2, observation: Faker::Lorem.paragraph(2, true, 4), name: 'Health Department',      category_ids: [8, 9, 1]},
  {id: 9,  type: 'ActorMeso',  user_id: 3, observation: Faker::Lorem.paragraph(2, true, 4), name: 'Transport Department',   category_ids: [9, 1, 2]},
  {id: 10, type: 'ActorMeso',  user_id: 1, observation: Faker::Lorem.paragraph(2, true, 4), name: 'Agriculture Department', category_ids: [1, 2, 3]},
  # Micros
  {id: 11, type: 'ActorMicro', user_id: 2, observation: Faker::Lorem.paragraph(2, true, 4), date_of_birth: Faker::Date.between(50.years.ago, 20.years.ago), title: 1, gender: 1, name: Faker::Name.title, category_ids: [2, 3, 4]},
  {id: 12, type: 'ActorMicro', user_id: 3, observation: Faker::Lorem.paragraph(2, true, 4), date_of_birth: Faker::Date.between(50.years.ago, 20.years.ago), title: 2, gender: 2, name: Faker::Name.title, category_ids: [3, 4, 5]},
  {id: 13, type: 'ActorMicro', user_id: 1, observation: Faker::Lorem.paragraph(2, true, 4), date_of_birth: Faker::Date.between(50.years.ago, 20.years.ago), title: 3, gender: 3, name: Faker::Name.title, category_ids: [4, 5, 6]},
  {id: 14, type: 'ActorMicro', user_id: 2, observation: Faker::Lorem.paragraph(2, true, 4), date_of_birth: Faker::Date.between(50.years.ago, 20.years.ago), title: 4, gender: 1, name: Faker::Name.title, category_ids: [5, 6, 7]},
  {id: 15, type: 'ActorMicro', user_id: 3, observation: Faker::Lorem.paragraph(2, true, 4), date_of_birth: Faker::Date.between(50.years.ago, 20.years.ago), title: 5, gender: 2, name: Faker::Name.title, category_ids: [6, 7, 8]}
)

ActorRelation.seed(:id,
  {id: 1, user_id: 1, parent_id: 1,  child_id: 6,  start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 1},
  {id: 1, user_id: 2, parent_id: 2,  child_id: 7,  start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 1},
  {id: 1, user_id: 3, parent_id: 3,  child_id: 8,  start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 1},
  {id: 1, user_id: 1, parent_id: 4,  child_id: 9,  start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 1},
  {id: 1, user_id: 2, parent_id: 5,  child_id: 10, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 1},
  {id: 1, user_id: 3, parent_id: 6,  child_id: 11, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 1},
  {id: 1, user_id: 1, parent_id: 7,  child_id: 12, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 2},
  {id: 1, user_id: 2, parent_id: 8,  child_id: 13, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 2},
  {id: 1, user_id: 3, parent_id: 9,  child_id: 14, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 2},
  {id: 1, user_id: 1, parent_id: 10, child_id: 15, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 2},
  {id: 1, user_id: 2, parent_id: 11, child_id: 9,  start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 2},
  {id: 1, user_id: 3, parent_id: 3,  child_id: 10, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 2},
  {id: 1, user_id: 1, parent_id: 4,  child_id: 11, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 2},
)

puts ''
puts '****************************************************************************'
puts '*                                                                          *'
puts '* Actors with relations and categories created                             *'
puts '*                                                                          *'
puts '****************************************************************************'
