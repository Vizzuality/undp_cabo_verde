# encoding: utf-8

require 'csv'
namespace :import do
  desc 'Import data from sample CSV files'
  task data: :enviroment do
  end


  desc 'Import categories'
  task categories: :environment do
    Category.delete_all
    puts "Import Social Cultural Domains"
    ["Economy", "Education", "Faith", "Family", "Politics"].each do |d|
      Category.create(
        name: d,
        type: "SocioCulturalDomain"
      )
    end

    puts "Import other domains"
    ["Agriculture", "Health", "Transport"].each do |d|
      Category.create(
        name: d,
        type: "OtherDomain"
      )
    end

    puts "Import organization types"
    ["IGO","NGO","UN Entity","Government Entity","Association",
     "Academia","Community based organization","Foundation",
     "Informal group (no legal status)","Parastatal",
     "Online group","Private sector","Public-private partnership",
     "Religious organization","Research organization or institution",
     "Development bank","Clan","Tribe"].each do |d|
       Category.create(
         name: d,
         type: "OrganizationType"
       )
     end

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
        name: row[0].presence,
        short_name: row[1].presence,
        title: ActorMicro::TITLES.index(row[2]),
        gender: row[3] == "male" ? 1 : 2,
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
        ],
        categories: Category.where(name: row[7].titleize,
                         type: "SocioCulturalDomain") +
                    Category.where(name: row[8] && row[8].split(",").map(&:titleize),
                                   type: "OtherDomain")
      )
    end
    puts "#{Actor.all.count} actors in the database"
  end

end
