# encoding: utf-8

require 'csv'
namespace :import do
  desc 'Import data from sample CSV files'
  task data: :environment do
    Rake::Task['db:seed'].invoke
    Rake::Task['import:categories'].invoke
    Rake::Task['import:individuals'].invoke
    Rake::Task['import:groups'].invoke
    Rake::Task['import:actions'].invoke
    Rake::Task['import:relationship_types'].invoke
    Rake::Task['import:relationships'].invoke
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
    user = User.where(email: "admin@vizzuality.com").first
    puts "Importing actors"
    file = File.join('lib', 'data', 'actors_individuals.csv')
    table = CSV.read(file)
    table.shift
    table.each do |row|
      ActorMicro.create(
        user_id: user.id,
        active: true,
        name: row[0] && row[0].strip,
        short_name: row[1] && row[1].strip,
        title: ActorMicro::TITLES.index(row[2].strip)+1,
        gender: row[3] == "male" ? 2: 3,
        localizations: [
          Localization.create({
            lat: row[4].strip,
            long: row[5].strip,
            user_id: 1
          })
        ],
        comments: [
          Comment.create({
            body: row[10],
            active: true,
            user_id: user.id
          })
        ],
        categories: Category.where(name: row[7].strip.titleize,
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
    user = User.where(email: "admin@vizzuality.com").first
    puts "Importing groups"
    file = File.join('lib', 'data', 'actors_groups.csv')
    table = CSV.read(file)
    table.shift
    table.each do |row|
      location = if row[3] && row[4]
                   [Localization.create({
                     lat: row[3].strip,
                     long: row[4].strip,
                     user_id: user.id
                   })]
                 else
                   []
                 end
      comment = if row[7]
                  [Comment.create({
                    body: row[7],
                    active: true,
                    user_id: user.id
                  })]
                else
                  []
                end
      Actor.create(
        user_id: user.id,
        active: true,
        type: "Actor"+row[11].titleize,
        name: row[0] && row[0].strip,
        short_name: row[1] && row[1].strip,
        other_names: row[2] && row[2].strip,
        legal_status: row[10] && row[10].strip,
        localizations: location,
        comments: comment,
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
    user = User.where(email: "admin@vizzuality.com").first
    puts "Importing actions"
    file = File.join('lib', 'data', 'actions.csv')
    table = CSV.read(file)
    table.shift
    table.each do |row|
      location = if row[3] && row[4]
                   [Localization.create({
                     lat: row[3].strip,
                     long: row[4].strip,
                     user_id: user.id
                   })]
                 else
                   []
                 end
      comment = if row[13]
                  [Comment.create({
                    body: row[13],
                    active: true,
                    user_id: user.id
                  })]
                else
                  []
                end
      Act.create(
        user_id: user.id,
        name: row[0] && row[0].strip,
        alternative_name: row[1] && row[1].strip,
        short_name: row[2] && row[2].strip,
        localizations: location,
        comments: comment,
        event: row[5].strip.downcase == 'event',
        human: row[6].strip.downcase == 'human',
        active: true,
        action_type: row[7].strip,
        type: "Act"+row[8].strip.titleize,
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

  desc "Import relationship types"
  task relationship_types: :environment do
    RelationType.delete_all
    puts "Adding relation types"
    [
      ["Belongs to", "Contains"],
      ["Indicators", "Indicator of"],
      ["Implements", "Implemented by"],
      ["Partners with", "Partners with"],
      ["Heads", "Headed by"],
      ["Benefits", "Benefits funds"],
      ["Funds", "Funded by"],
      ["Implements", "Implemented by"]
    ].each do |type|
      RelationType.create(
        title: type[0],
        title_reverse: type[1]
      )
    end

    puts "#{RelationType.count} relation types added"
  end

  desc "Import relationships"
  task relationships: :environment do
    ActorRelation.delete_all
    ActActorRelation.delete_all
    user = User.where(email: "admin@vizzuality.com").first
    file = File.join('lib', 'data', 'relationships.csv')
    table = CSV.read(file)
    table.shift
    table.each do |row|
      next if [row[1], row[4]].include?("Artifact")
      row[3].split(",").each do |types|
        type = RelationType.where("LOWER(title) = LOWER(?)", types.strip).first
        actor = Actor.where("UPPER(name) =  UPPER(?)", row[2].strip).first
        if row[4] == 'Action'
          action = Act.where("UPPER(name) = UPPER(?)", row[5].strip).first
          ActActorRelation.create(
            user_id: user.id,
            actor_id: actor.id,
            act_id: action.id,
            relation_type_id: type.id,
            start_date: row[7] && Date.parse(row[7]),
            end_date: row[8] && Date.parse(row[8])
          )
        else
          parent = Actor.where("UPPER(name) =  UPPER(?)", row[5].strip).first
          next unless parent
          ActorRelation.create(
            child_id: actor.id,
            parent_id: parent.id,
            user_id: user.id,
            start_date: row[7] && Date.parse(row[7]),
            end_date: row[8] && Date.parse(row[8]),
            relation_type_id: type.id
          )
        end
      end
    end
    puts "#{ActorRelation.count} actor relations added"
    puts "#{ActActorRelation.count} actor actions relations added"
  end
end
