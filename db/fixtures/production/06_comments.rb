Comment.seed(:id,
  {id: 1,  commentable_id: 1, commentable_type: 'Actor', body: Faker::Lorem.paragraph, user_id: 1},
  {id: 2,  commentable_id: 2, commentable_type: 'Act',   body: Faker::Lorem.paragraph, user_id: 2},
  {id: 3,  commentable_id: 3, commentable_type: 'Actor', body: Faker::Lorem.paragraph, user_id: 3},
  {id: 4,  commentable_id: 4, commentable_type: 'Act',   body: Faker::Lorem.paragraph, user_id: 1},
  {id: 5,  commentable_id: 5, commentable_type: 'Actor', body: Faker::Lorem.paragraph, user_id: 2},
  {id: 6,  commentable_id: 6, commentable_type: 'Act',   body: Faker::Lorem.paragraph, user_id: 3},
  {id: 7,  commentable_id: 7, commentable_type: 'Actor', body: Faker::Lorem.paragraph, user_id: 1},
  {id: 8,  commentable_id: 8, commentable_type: 'Act',   body: Faker::Lorem.paragraph, user_id: 2},
  {id: 9,  commentable_id: 9, commentable_type: 'Actor', body: Faker::Lorem.paragraph, user_id: 3},
  {id: 10, commentable_id: 1, commentable_type: 'Act',   body: Faker::Lorem.paragraph, user_id: 1},
  {id: 11, commentable_id: 2, commentable_type: 'Act',   body: Faker::Lorem.paragraph, user_id: 2},
  {id: 12, commentable_id: 3, commentable_type: 'Act',   body: Faker::Lorem.paragraph, user_id: 3},
  {id: 13, commentable_id: 4, commentable_type: 'Actor', body: Faker::Lorem.paragraph, user_id: 1},
  {id: 14, commentable_id: 5, commentable_type: 'Actor', body: Faker::Lorem.paragraph, user_id: 2},
  {id: 15, commentable_id: 6, commentable_type: 'Act',   body: Faker::Lorem.paragraph, user_id: 3}
)

puts ''
puts '****************************************************************************'
puts '*                                                                          *'
puts '* Comments created on acts and actors                                      *'
puts '*                                                                          *'
puts '****************************************************************************'