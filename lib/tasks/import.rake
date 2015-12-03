# encoding: utf-8

require 'csv'
namespace :import do
  desc 'Import data from sample CSV files'
  task data: :enviroment do
    Rake::Task['import:categories'].invoke
    Rake::Task['import:individuals'].invoke
    Rake::Task['import:groups'].invoke
    Rake::Task['import:actions'].invoke
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

     puts "Import Scales (OperationalField)"
     state; county; municipality; national; regional; global; local
     ["State", "County", "Municipality", "National", "Regional",
      "Global", "Local"].each do |scale|
       Category.create(
         name: scale,
         type: "OperationalField"
       )
     end
  end

  desc 'Import micro actors data from sample CSV files'
  task individuals: :environment do
    ActorMicro.delete_all
    puts "Importing actors"
    file = File.join('lib', 'data', 'actors_individuals.csv')
    table = CSV.read(file)
    table.shift
    table.each do |row|
      ActorMicro.create(
        active: true,
        name: row[0].presence,
        short_name: row[1].presence,
        title: ActorMicro::TITLES.index(row[2])+1,
        gender: row[3] == "male" ? 2: 3,
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
    puts "#{ActorMicro.all.count} actors in the database"
  end

  desc 'Import meso macro actors data from sample CSV files'
  task groups: :environment do
    Actor.where(type: ["ActorMeso", "ActorMacro"]).delete_all
    puts "Importing groups"
    file = File.join('lib', 'data', 'actors_groups.csv')
    table = CSV.read(file)
    table.shift
    table.each do |row|
      Actor.create(
        active: true,
        type: "Actor"+row[11].titleize,
        name: row[0].presence,
        short_name: row[1].presence,
        other_names: row[2].presence,
        legal_status: row[10].presence,
        localizations: [
          Localization.create({
            lat: row[3],
            long: row[4]
          })
        ],
        comments: [
          Comment.create({
            body: row[7],
            active: true
          })
        ],
        categories: Category.where(name: row[12].titleize,
                         type: "SocioCulturalDomain") +
                    Category.where(name: row[12].titleize,
                                   type: 'SocioCulturalDomain') +
                    Category.where(name: row[13] && row[13].titleize,
                                   type: 'OtherDomain') +
                    Category.where(name: row[9],
                                   type: 'OrganizationType') +
                    Category.where(name: row[8].titleize,
                                   type: 'OperationalField')
      )
    end
    puts "#{Actor.where(type: ['ActorMeso', 'ActorMacro']).
      count} actors in the database"
  end

  desc 'Import Actions from sample CSV file'
  task actions: :environment do
    Act.delete_all
    puts "Importing actions"
    file = File.join('lib', 'data', 'actions.csv')
    table = CSV.read(file)
    table.shift
    table.each do |row|
      Act.create(
        name: row[0].presence,
        alternative_name: row[1].presence,
        short_name: row[2].presence,
        localizations: [
          Localization.create({
            lat: row[3],
            long: row[4]
          })
        ],
        comments: [
          Comment.create({
            body: row[13],
            active: true
          })
        ],
        event: row[5].downcase == 'event',
        human: row[6].downcase == 'human',
        active: true,
        action_type: row[7],
        type: "Act"+row[8].titleize,
        start_date: row[9] && Date.parse(row[9]),
        end_date: row[10] && Date.parse(row[10]),
        description: row[11].presence,
        budget: row[12].presence,
        categories: Category.where(name: row[14] && row[14].titleize,
                         type: "SocioCulturalDomain") +
                    Category.where(name: row[15] && row[15].split(",").map(&:titleize),
                                   type: "OtherDomain")
      )
    end

    puts "#{Act.count} actions in the database"
  end
end
