Act.seed(:id,
  # Macros
  {id: 1,  type: 'ActMacro', user_id: 1, description: Faker::Lorem.paragraph(2, true, 4), start_date: Faker::Date.between(10.years.ago, 2.years.ago),                                                          name: Faker::Lorem.sentence, alternative_name: Faker::Lorem.sentence(3, true, 4), short_name: Faker::Lorem.sentence(3), event: false, human: true,  category_ids: [1, 2, 3, 25]},
  {id: 2,  type: 'ActMacro', user_id: 2, description: Faker::Lorem.paragraph(2, true, 4), start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), name: Faker::Lorem.sentence, alternative_name: Faker::Lorem.sentence(3, true, 4), short_name: Faker::Lorem.sentence(3), event: true,  human: false, category_ids: [2, 3, 4, 26]},
  {id: 3,  type: 'ActMacro', user_id: 3, description: Faker::Lorem.paragraph(2, true, 4), start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), name: Faker::Lorem.sentence, alternative_name: Faker::Lorem.sentence(3, true, 4), short_name: Faker::Lorem.sentence(3), event: true,  human: true,  category_ids: [3, 4, 5, 27]},
  {id: 4,  type: 'ActMacro', user_id: 1, description: Faker::Lorem.paragraph(2, true, 4), start_date: Faker::Date.between(10.years.ago, 2.years.ago),                                                          name: Faker::Lorem.sentence, alternative_name: Faker::Lorem.sentence(3, true, 4), short_name: Faker::Lorem.sentence(3), event: true,  human: true,  category_ids: [4, 5, 6, 28]},
  {id: 5,  type: 'ActMacro', user_id: 2, description: Faker::Lorem.paragraph(2, true, 4), start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), name: Faker::Lorem.sentence, alternative_name: Faker::Lorem.sentence(3, true, 4), short_name: Faker::Lorem.sentence(3), event: false, human: false, category_ids: [5, 6, 7, 29]},
  # Mesos
  {id: 6,  type: 'ActMeso',  user_id: 3, description: Faker::Lorem.paragraph(2, true, 4), start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), name: Faker::Lorem.sentence, alternative_name: Faker::Lorem.sentence(3, true, 4), short_name: Faker::Lorem.sentence(3), event: true,  human: false, category_ids: [6, 7, 8, 30]},
  {id: 7,  type: 'ActMeso',  user_id: 1, description: Faker::Lorem.paragraph(2, true, 4), start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), name: Faker::Lorem.sentence, alternative_name: Faker::Lorem.sentence(3, true, 4), short_name: Faker::Lorem.sentence(3), event: false, human: false, category_ids: [7, 8, 9, 31]},
  {id: 8,  type: 'ActMeso',  user_id: 2, description: Faker::Lorem.paragraph(2, true, 4), start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), name: Faker::Lorem.sentence, alternative_name: Faker::Lorem.sentence(3, true, 4), short_name: Faker::Lorem.sentence(3), event: true,  human: true,  category_ids: [8, 9, 1, 32]},
  {id: 9,  type: 'ActMeso',  user_id: 3, description: Faker::Lorem.paragraph(2, true, 4), start_date: Faker::Date.between(10.years.ago, 2.years.ago),                                                          name: Faker::Lorem.sentence, alternative_name: Faker::Lorem.sentence(3, true, 4), short_name: Faker::Lorem.sentence(3), event: true,  human: true,  category_ids: [9, 1, 2, 33]},
  {id: 10, type: 'ActMeso',  user_id: 1, description: Faker::Lorem.paragraph(2, true, 4), start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), name: Faker::Lorem.sentence, alternative_name: Faker::Lorem.sentence(3, true, 4), short_name: Faker::Lorem.sentence(3), event: true,  human: true,  category_ids: [1, 2, 3, 25]},
  # Micros
  {id: 11, type: 'ActMicro', user_id: 2, description: Faker::Lorem.paragraph(2, true, 4), start_date: Faker::Date.between(10.years.ago, 2.years.ago),                                                          name: Faker::Lorem.sentence, alternative_name: Faker::Lorem.sentence(3, true, 4), short_name: Faker::Lorem.sentence(3), event: false, human: false, category_ids: [2, 3, 4, 26]},
  {id: 12, type: 'ActMicro', user_id: 3, description: Faker::Lorem.paragraph(2, true, 4), start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), name: Faker::Lorem.sentence, alternative_name: Faker::Lorem.sentence(3, true, 4), short_name: Faker::Lorem.sentence(3), event: false, human: false, category_ids: [3, 4, 5, 27]},
  {id: 13, type: 'ActMicro', user_id: 1, description: Faker::Lorem.paragraph(2, true, 4), start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), name: Faker::Lorem.sentence, alternative_name: Faker::Lorem.sentence(3, true, 4), short_name: Faker::Lorem.sentence(3), event: true,  human: true,  category_ids: [4, 5, 6, 28]},
  {id: 14, type: 'ActMicro', user_id: 2, description: Faker::Lorem.paragraph(2, true, 4), start_date: Faker::Date.between(10.years.ago, 2.years.ago),                                                          name: Faker::Lorem.sentence, alternative_name: Faker::Lorem.sentence(3, true, 4), short_name: Faker::Lorem.sentence(3), event: true,  human: false, category_ids: [5, 6, 7, 29]},
  {id: 15, type: 'ActMicro', user_id: 3, description: Faker::Lorem.paragraph(2, true, 4), start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), name: Faker::Lorem.sentence, alternative_name: Faker::Lorem.sentence(3, true, 4), short_name: Faker::Lorem.sentence(3), event: false, human: true,  category_ids: [6, 7, 8, 30]}
)

ActRelation.seed(:id,
  {id: 1, user_id: 1, parent_id: 1,  child_id: 6,  start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 14},
  {id: 1, user_id: 2, parent_id: 2,  child_id: 7,  start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 14},
  {id: 1, user_id: 3, parent_id: 3,  child_id: 8,  start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 14},
  {id: 1, user_id: 1, parent_id: 4,  child_id: 9,  start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 14},
  {id: 1, user_id: 2, parent_id: 5,  child_id: 10, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 14},
  {id: 1, user_id: 3, parent_id: 6,  child_id: 11, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 14},
  {id: 1, user_id: 1, parent_id: 7,  child_id: 12, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 14},
  {id: 1, user_id: 2, parent_id: 8,  child_id: 13, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 14},
  {id: 1, user_id: 3, parent_id: 9,  child_id: 14, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 14},
  {id: 1, user_id: 1, parent_id: 10, child_id: 15, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 14},
  {id: 1, user_id: 2, parent_id: 11, child_id: 9,  start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 14},
  {id: 1, user_id: 3, parent_id: 3,  child_id: 10, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 14},
  {id: 1, user_id: 1, parent_id: 4,  child_id: 11, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 14}
)

ActActorRelation.seed(:id,
  {id: 1, user_id: 1, actor_id: 1,  act_id: 6,  start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 3},
  {id: 1, user_id: 2, actor_id: 2,  act_id: 7,  start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 3},
  {id: 1, user_id: 3, actor_id: 3,  act_id: 8,  start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 3},
  {id: 1, user_id: 1, actor_id: 4,  act_id: 9,  start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 3},
  {id: 1, user_id: 2, actor_id: 5,  act_id: 10, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 3},
  {id: 1, user_id: 3, actor_id: 6,  act_id: 11, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 3},
  {id: 1, user_id: 1, actor_id: 7,  act_id: 12, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 3},
  {id: 1, user_id: 2, actor_id: 8,  act_id: 13, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 4},
  {id: 1, user_id: 3, actor_id: 9,  act_id: 14, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 4},
  {id: 1, user_id: 1, actor_id: 10, act_id: 15, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 4},
  {id: 1, user_id: 2, actor_id: 11, act_id: 9,  start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 4},
  {id: 1, user_id: 3, actor_id: 3,  act_id: 10, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 4},
  {id: 1, user_id: 1, actor_id: 4,  act_id: 11, start_date: Faker::Date.between(10.years.ago, 2.years.ago), end_date: Faker::Date.between(2.years.ago, 20.days.ago), relation_type_id: 4}
)

puts ''
puts '****************************************************************************'
puts '*                                                                          *'
puts '* Acts with relations and categories created                               *'
puts '*                                                                          *'
puts '****************************************************************************'
