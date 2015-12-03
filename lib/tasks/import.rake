# encoding: utf-8

require 'csv'
namespace :import do
  desc 'Import data from sample CSV files'
  task data: :enviroment do
  end


  desc 'Import actors data from sample CSV files'
  task actors: :environment do
    Actor.delete_all
    puts "Importing actors"
    file = File.join('lib', 'data', 'actors_individuals.csv')
    table = CSV.read(file)
    table.shift
    table.each do |row|
      Actor.create(
        type: 'ActorMicro',
        name: row[0],
        short_name: row[1],
        title: row[2],
        gender: row[3],
        localizations: [
          Localization.create({
            lat: row[4],
            long: row[5]
          })
        ],
        comments: [
          Comment.create({
            body: row[10],
            active: true
          })
        ]
      )
    end
    puts "#{Actor.all.count} actors in the database"
  end

end
