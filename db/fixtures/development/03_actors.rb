Actor.seed(:id,
  # Macros
  {id: 1,  type: 'ActorMacro', user_id: 1, observation: Faker::Lorem.paragraph(2, true, 4), operational_field: 18, name: 'Economy Organization',  category_ids: [1, 2, 3, 25]},
  {id: 2,  type: 'ActorMacro', user_id: 2, observation: Faker::Lorem.paragraph(2, true, 4), operational_field: 19, name: 'Education Institution', category_ids: [2, 3, 4, 26]},
  {id: 3,  type: 'ActorMacro', user_id: 3, observation: Faker::Lorem.paragraph(2, true, 4), operational_field: 20, name: 'Faith Organization',    category_ids: [3, 4, 5, 27, 30]},
  {id: 4,  type: 'ActorMacro', user_id: 1, observation: Faker::Lorem.paragraph(2, true, 4), operational_field: 21, name: 'Family Institution',    category_ids: [4, 5, 6, 28, 31]},
  {id: 5,  type: 'ActorMacro', user_id: 2, observation: Faker::Lorem.paragraph(2, true, 4), operational_field: 22, name: 'Politics Institution',  category_ids: [5, 6, 7, 29, 32]},
  # Mesos
  {id: 6,  type: 'ActorMeso',  user_id: 3, observation: Faker::Lorem.paragraph(2, true, 4), name: 'Agriculture Department', category_ids: [6, 7, 8, 25, 26]},
  {id: 7,  type: 'ActorMeso',  user_id: 1, observation: Faker::Lorem.paragraph(2, true, 4), name: 'Fishery Department',     category_ids: [7, 8, 9, 26, 27, 28]},
  {id: 8,  type: 'ActorMeso',  user_id: 2, observation: Faker::Lorem.paragraph(2, true, 4), name: 'Health Department',      category_ids: [8, 9, 1, 27, 28, 29]},
  {id: 9,  type: 'ActorMeso',  user_id: 3, observation: Faker::Lorem.paragraph(2, true, 4), name: 'Transport Department',   category_ids: [9, 1, 2, 28, 29, 30]},
  {id: 10, type: 'ActorMeso',  user_id: 1, observation: Faker::Lorem.paragraph(2, true, 4), name: 'Agriculture Department', category_ids: [1, 2, 3, 29, 30, 31]},
  # Micros
  {id: 11, type: 'ActorMicro', user_id: 2, observation: Faker::Lorem.paragraph(2, true, 4), title: 1, gender: 1, name: Faker::Name.title, category_ids: [2, 3, 4, 25, 30]},
  {id: 12, type: 'ActorMicro', user_id: 3, observation: Faker::Lorem.paragraph(2, true, 4), title: 2, gender: 2, name: Faker::Name.title, category_ids: [3, 4, 5, 26, 31]},
  {id: 13, type: 'ActorMicro', user_id: 1, observation: Faker::Lorem.paragraph(2, true, 4), title: 3, gender: 3, name: Faker::Name.title, category_ids: [4, 5, 6, 27, 32]},
  {id: 14, type: 'ActorMicro', user_id: 2, observation: Faker::Lorem.paragraph(2, true, 4), title: 4, gender: 1, name: Faker::Name.title, category_ids: [5, 6, 7, 28, 33]},
  {id: 15, type: 'ActorMicro', user_id: 3, observation: Faker::Lorem.paragraph(2, true, 4), title: 5, gender: 2, name: Faker::Name.title, category_ids: [6, 7, 8, 29, 30]}
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
