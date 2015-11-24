Localization.seed(:id,
  {id: 1,  user_id: 1, name: Faker::Address.secondary_address, country: Faker::Address.country, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state, district: Faker::Address.city_prefix, lat: Faker::Address.latitude, long: Faker::Address.longitude, web_url: Faker::Internet.url},
  {id: 2,  user_id: 1, name: Faker::Address.secondary_address, country: Faker::Address.country, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state, district: Faker::Address.city_prefix, lat: Faker::Address.latitude, long: Faker::Address.longitude, web_url: Faker::Internet.url},
  {id: 3,  user_id: 1, name: Faker::Address.secondary_address, country: Faker::Address.country, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state, district: Faker::Address.city_prefix, lat: Faker::Address.latitude, long: Faker::Address.longitude, web_url: Faker::Internet.url},
  {id: 4,  user_id: 1, name: Faker::Address.secondary_address, country: Faker::Address.country, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state, district: Faker::Address.city_prefix, lat: Faker::Address.latitude, long: Faker::Address.longitude, web_url: Faker::Internet.url},
  {id: 5,  user_id: 1, name: Faker::Address.secondary_address, country: Faker::Address.country, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state, district: Faker::Address.city_prefix, lat: Faker::Address.latitude, long: Faker::Address.longitude, web_url: Faker::Internet.url},
  {id: 6,  user_id: 2, name: Faker::Address.secondary_address, country: Faker::Address.country, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state, district: Faker::Address.city_prefix, lat: Faker::Address.latitude, long: Faker::Address.longitude, web_url: Faker::Internet.url},
  {id: 7,  user_id: 2, name: Faker::Address.secondary_address, country: Faker::Address.country, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state, district: Faker::Address.city_prefix, lat: Faker::Address.latitude, long: Faker::Address.longitude, web_url: Faker::Internet.url},
  {id: 8,  user_id: 2, name: Faker::Address.secondary_address, country: Faker::Address.country, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state, district: Faker::Address.city_prefix, lat: Faker::Address.latitude, long: Faker::Address.longitude, web_url: Faker::Internet.url},
  {id: 9,  user_id: 2, name: Faker::Address.secondary_address, country: Faker::Address.country, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state, district: Faker::Address.city_prefix, lat: Faker::Address.latitude, long: Faker::Address.longitude, web_url: Faker::Internet.url},
  {id: 10, user_id: 2, name: Faker::Address.secondary_address, country: Faker::Address.country, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state, district: Faker::Address.city_prefix, lat: Faker::Address.latitude, long: Faker::Address.longitude, web_url: Faker::Internet.url},
  {id: 11, user_id: 2, name: Faker::Address.secondary_address, country: Faker::Address.country, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state, district: Faker::Address.city_prefix, lat: Faker::Address.latitude, long: Faker::Address.longitude, web_url: Faker::Internet.url},
  {id: 12, user_id: 3, name: Faker::Address.secondary_address, country: Faker::Address.country, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state, district: Faker::Address.city_prefix, lat: Faker::Address.latitude, long: Faker::Address.longitude, web_url: Faker::Internet.url},
  {id: 13, user_id: 3, name: Faker::Address.secondary_address, country: Faker::Address.country, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state, district: Faker::Address.city_prefix, lat: Faker::Address.latitude, long: Faker::Address.longitude, web_url: Faker::Internet.url},
  {id: 14, user_id: 3, name: Faker::Address.secondary_address, country: Faker::Address.country, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state, district: Faker::Address.city_prefix, lat: Faker::Address.latitude, long: Faker::Address.longitude, web_url: Faker::Internet.url},
  {id: 15, user_id: 3, name: Faker::Address.secondary_address, country: Faker::Address.country, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state, district: Faker::Address.city_prefix, lat: Faker::Address.latitude, long: Faker::Address.longitude, web_url: Faker::Internet.url}
)

ActLocalization.seed(:id,
  {id: 1,  localization_id: 1,  act_id: 1},
  {id: 2,  localization_id: 2,  act_id: 2},
  {id: 3,  localization_id: 3,  act_id: 3},
  {id: 4,  localization_id: 4,  act_id: 4},
  {id: 5,  localization_id: 5,  act_id: 5},
  {id: 6,  localization_id: 6,  act_id: 6},
  {id: 7,  localization_id: 7,  act_id: 7},
  {id: 8,  localization_id: 8,  act_id: 8},
  {id: 9,  localization_id: 9,  act_id: 9},
  {id: 10, localization_id: 10, act_id: 10},
  {id: 11, localization_id: 11, act_id: 11},
  {id: 12, localization_id: 12, act_id: 12},
  {id: 13, localization_id: 13, act_id: 13},
  {id: 14, localization_id: 14, act_id: 14},
  {id: 15, localization_id: 15, act_id: 15},
  {id: 16, localization_id: 10, act_id: 1},
  {id: 17, localization_id: 11, act_id: 2}
)

ActorLocalization.seed(:id,
  {id: 1,  localization_id: 1,  actor_id: 1},
  {id: 2,  localization_id: 2,  actor_id: 2},
  {id: 3,  localization_id: 3,  actor_id: 3},
  {id: 4,  localization_id: 4,  actor_id: 4},
  {id: 5,  localization_id: 5,  actor_id: 5},
  {id: 6,  localization_id: 6,  actor_id: 6},
  {id: 7,  localization_id: 7,  actor_id: 7},
  {id: 8,  localization_id: 8,  actor_id: 8},
  {id: 9,  localization_id: 9,  actor_id: 9},
  {id: 10, localization_id: 10, actor_id: 10},
  {id: 11, localization_id: 11, actor_id: 11},
  {id: 12, localization_id: 12, actor_id: 12},
  {id: 13, localization_id: 13, actor_id: 13},
  {id: 14, localization_id: 14, actor_id: 14},
  {id: 15, localization_id: 15, actor_id: 15},
  {id: 16, localization_id: 10, actor_id: 1},
  {id: 17, localization_id: 11, actor_id: 2}
)

puts ''
puts '****************************************************************************'
puts '*                                                                          *'
puts '* Localizations created and added to actors and acts                       *'
puts '*                                                                          *'
puts '****************************************************************************'
