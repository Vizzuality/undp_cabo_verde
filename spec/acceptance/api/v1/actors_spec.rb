# encoding: UTF-8
require 'acceptance_helper'

resource 'Actors' do
  header "Accept", "application/json; application/undp-cabo-verde-v1+json"
  header "Content-Type", "application/json"
  header 'Host', 'undp-cabo-verde.herokuapp.com'

  before :each do
    @user       = FactoryGirl.create(:random_user)
    @location   = FactoryGirl.create(:localization, user: @user)
    @location_2 = FactoryGirl.create(:localization, user: @user)
    @location_3 = FactoryGirl.create(:localization, user: @user)
    @location_4 = FactoryGirl.create(:localization, user: @user)
    @location_5 = FactoryGirl.create(:localization, user: @user)
    @category_1 = FactoryGirl.create(:category, name: 'Category one')
    @category_2 = FactoryGirl.create(:category, name: 'Category two', type: 'SocioCulturalDomain')
    @category_3 = FactoryGirl.create(:category, name: 'Category three',  type: 'OrganizationType')
    @field      = FactoryGirl.create(:operational_field, name: 'Global')
  end

  context 'Actors API Version 1' do
    let!(:actors) do
      actors = []

      actors << create(:actor_macro, name: 'Economy Organization', user: @user,
                        observation: Faker::Lorem.paragraph(2, true, 4), operational_field: @field,
                        localizations: [@location, @location_2], short_name: Faker::Name.name,
                        legal_status: Faker::Name.name, other_names: Faker::Name.name,
                        categories: [@category_1, @category_2, @category_3])
      actors << create(:actor_macro, name: 'Education Institution', localizations: [@location_3],
                        user: @user, observation: Faker::Lorem.paragraph(2, true, 4), categories: [@category_2])
      actors << create(:actor_meso,  name: 'Department of Education',
                        user: @user, observation: Faker::Lorem.paragraph(2, true, 4),
                        localizations: [@location_4], short_name: Faker::Name.name,
                        legal_status: Faker::Name.name, other_names: Faker::Name.name, categories: [@category_1, @category_2])
      actors << create(:actor_micro, name: 'Director of Department',
                        user: @user, observation: Faker::Lorem.paragraph(2, true, 4),
                        localizations: [@location_5], gender: 2,
                        title: 2, categories: [@category_2])

      actors.each do |a|
        a.touch
      end

      actors
    end

    context 'Actors list' do
      get "/api/actors" do
        example_request 'Getting a list of actors' do
          actor_1 = JSON.parse(response_body)['actors'][0]
          actor_2 = JSON.parse(response_body)['actors'][1]
          actor_3 = JSON.parse(response_body)['actors'][2]
          actor_4 = JSON.parse(response_body)['actors'][3]

          expect(status).to eq(200)
          expect(actor_1['level']).to eq('micro')
          expect(actor_2['level']).to eq('meso')
          expect(actor_3['name']).to  eq('Education Institution')
          expect(actor_3['level']).to eq('macro')
          expect(actor_4['name']).to  eq('Economy Organization')

          expect(actor_4['locations'][0]['lat']).not_to be_nil
          expect(actor_1['locations'].size).to eq(1)
          expect(actor_2['locations'].size).to eq(1)
          expect(actor_3['locations'].size).to eq(1)
          expect(actor_4['locations'].size).to eq(2)
        end
      end

      context 'Actors list filtered by level or SCD' do
        get "/api/actors" do
          parameter :levels, 'Filter actors by level (micro, meso or macro)'
          parameter :domains_ids, 'Filter actors by socio cultural domain'

          example 'Getting a list of micro actors' do
            do_request(levels: ['micro'])
            response_actors = JSON.parse(response_body)['actors']
            expect(status).to eq(200)
            expect(response_actors.size).to eq(1)
          end

          example 'Getting a list of micro and meso actors' do
            do_request(levels: ['micro', 'meso'])
            response_actors = JSON.parse(response_body)['actors']
            expect(status).to eq(200)
            expect(response_actors.size).to eq(2)
          end

          example 'Getting a list of actors with a social cultural domain' do
            do_request(domains_ids: [@category_1.id])
            response_actors = JSON.parse(response_body)['actors']
            expect(status).to eq(200)
            expect(response_actors.size).to eq(2)
          end
        end
      end

      context 'Actors list filtered by date' do
        before :each do
          # Time.local(2015, 9, 1, 12, 0, 0, 0)
          actors[0].localizations[0].update_attributes(start_date: Time.zone.now - 4.years, end_date: Time.zone.now - 3.years)
          actors[0].localizations[1].update_attributes(start_date: Time.zone.now - 2.years, end_date: Time.zone.now - 1.year)
          actors[1].localizations[0].update_attributes(start_date: Time.zone.now,           end_date: Time.zone.now + 1.year)
          actors[2].localizations[0].update_attributes(start_date: Time.zone.now - 1.day,   end_date: Time.zone.now + 2.days)
          actors[3].localizations[0].update_attributes(start_date: Time.zone.now - 1.year,  end_date: Time.zone.now)
        end

        get "/api/actors" do
          parameter :start_date, 'Filter actors by start-date (2014-01-31)'
          parameter :end_date, 'Filter actors by end-date (2015-01-31)'

          example 'Getting a list of actors by start-date' do
            do_request(start_date: '2015-01-31')
            response_actors = JSON.parse(response_body)['actors']
            expect(status).to eq(200)
            expect(response_actors.size).to eq(3)
          end

          example 'Getting a list of actors by end-date' do
            do_request(end_date: '2015-01-31')
            response_actors = JSON.parse(response_body)['actors']
            expect(status).to eq(200)
            expect(response_actors.size).to eq(2)
          end

          example 'Getting a list of actors by start-date and end-date' do
            do_request(start_date: '2014-01-31', end_date: '2015-09-31')
            response_actors = JSON.parse(response_body)['actors']
            expect(status).to eq(200)
            expect(response_actors.size).to eq(4)
            expect(response_actors[0]['locations'].size).to eq(1)
            expect(response_actors[1]['locations'].size).to eq(1)
            expect(response_actors[2]['locations'].size).to eq(1)
            expect(response_actors[3]['locations'].size).to eq(1)
          end

          example 'Getting a list of actors by start-date and end-date check locations filtering', document: false do
            do_request(start_date: '2010-01-31', end_date: '2015-09-31')
            response_actors = JSON.parse(response_body)['actors']
            expect(status).to eq(200)
            expect(response_actors.size).to eq(4)
            expect(response_actors[0]['locations'].size).to eq(2)
            expect(response_actors[1]['locations'].size).to eq(1)
            expect(response_actors[2]['locations'].size).to eq(1)
            expect(response_actors[3]['locations'].size).to eq(1)
          end
        end
      end
    end

    context 'Actor details' do
      get "/api/actors/:id" do
        parameter :start_date, 'Filter actors by start-date (2014-01-31)'
        parameter :end_date, 'Filter actors by end-date (2015-01-31)'

        example 'Getting a specific actor with locations' do
          do_request(id: actors.first.id)
          actor = JSON.parse(response_body)['actor']

          expect(status).to eq(200)
          expect(actor['id']).to    eq(actors.first.id)
          expect(actor['name']).to  eq('Economy Organization')
          expect(actor['level']).to eq('macro')
          expect(actor['scale']).to match('Global')
          expect(actor['observation']).not_to              be_nil
          expect(actor['short_name']).not_to               be_nil
          expect(actor['legal_status']).not_to             be_nil
          expect(actor['other_names']).not_to              be_nil
          expect(actor['locations'][0]['name']).not_to     be_nil
          expect(actor['locations'][0]['country']).not_to  be_nil
          expect(actor['locations'][0]['city']).not_to     be_nil
          expect(actor['locations'][0]['zip_code']).not_to be_nil
          expect(actor['locations'][0]['state']).not_to    be_nil
          expect(actor['locations'][0]['district']).not_to be_nil
          expect(actor['locations'][0]['web_url']).not_to  be_nil
          expect(actor['locations'][0]['lat']).not_to      be_nil
          expect(actor['locations'][0]['long']).not_to     be_nil
          expect(actor['locations'][0]['start_date']).to   be_nil
          expect(actor['locations'][0]['end_date']).to     be_nil

          expect(actor['locations'][0]['main']).to         eq(false)
          expect(actor['locations'][1]['main']).to         eq(true)

          # Micro specific
          expect(actor['title']).to  be_nil
          expect(actor['gender']).to be_nil

          expect(actor['organization_types'][0]['name']).not_to be_nil
          expect(actor['organization_types'][0]['type']).to     eq('Organization type')
        end

        context 'Time filtering for actor' do
          before :each do
            # Time.local(2015, 9, 1, 12, 0, 0, 0)
            actors[0].localizations[0].update_attributes(start_date: Time.zone.now - 4.years, end_date: Time.zone.now - 3.years)
            actors[0].localizations[1].update_attributes(start_date: Time.zone.now - 2.years, end_date: Time.zone.now - 1.year)
          end

          example 'Getting a specific actor with locations filtering by end_date and start_date', document: false do
            do_request(id: actors[0].id, start_date: '2014-01-31', end_date: '2015-09-31')
            actor = JSON.parse(response_body)['actor']

            expect(status).to eq(200)
            expect(actor['id']).to    eq(actors.first.id)
            expect(actor['name']).to  eq('Economy Organization')
            expect(actor['locations'].size).to             eq(1)
            expect(actor['locations'][0]['id']).not_to     be_nil
            expect(actor['locations'][0]['lat']).not_to    be_nil
            expect(actor['locations'][0]['long']).not_to   be_nil
            expect(actor['locations'][0]['start_date']).to eq('2013-09-01')
            expect(actor['locations'][0]['end_date']).to   eq('2014-09-01')
            expect(actor['locations'][0]['main']).to       eq(false)
          end

          example 'Getting a specific actor with locations filtering by end_date', document: false do
            do_request(id: actors[0].id, end_date: '2012-09-31')
            actor = JSON.parse(response_body)['actor']

            expect(status).to eq(200)
            expect(actor['id']).to    eq(actors.first.id)
            expect(actor['name']).to  eq('Economy Organization')
            expect(actor['locations'].size).to             eq(1)
            expect(actor['locations'][0]['start_date']).to eq('2011-09-01')
            expect(actor['locations'][0]['end_date']).to   eq('2012-09-01')
            expect(actor['locations'][0]['main']).to       eq(true)
          end

          example 'Getting a specific actor with locations filtering by start_date', document: false do
            do_request(id: actors[0].id, start_date: '2014-01-01')
            actor = JSON.parse(response_body)['actor']

            expect(status).to eq(200)
            expect(actor['id']).to    eq(actors.first.id)
            expect(actor['name']).to  eq('Economy Organization')
            expect(actor['locations'].size).to             eq(1)
            expect(actor['locations'][0]['start_date']).to eq('2013-09-01')
            expect(actor['locations'][0]['end_date']).to   eq('2014-09-01')
            expect(actor['locations'][0]['main']).to       eq(false)
          end
        end

        example 'Getting a meso actor', document: false do
          do_request(id: actors.third.id)
          actor = JSON.parse(response_body)['actor']

          expect(status).to eq(200)
          expect(actor['level']).to eq('meso')
          expect(actor['short_name']).not_to   be_nil
          expect(actor['legal_status']).not_to be_nil
          expect(actor['other_names']).not_to  be_nil
          # Macro specific
          expect(actor['scale']).to  be_nil
          # Micro specific
          expect(actor['title']).to  be_nil
          expect(actor['gender']).to be_nil

          expect(actor['other_domains'][0]['name']).not_to be_nil
          expect(actor['other_domains'][0]['type']).to eq('Other domains')
        end

        example 'Getting a micro actor', document: false do
          do_request(id: actors[3].id)
          actor = JSON.parse(response_body)['actor']

          expect(status).to eq(200)
          expect(actor['level']).to  eq('micro')
          expect(actor['gender']).to eq('Male')
          expect(actor['title']).to  eq('Ms.')

          expect(actor['socio_cultural_domains'][0]['name']).not_to be_nil
          expect(actor['socio_cultural_domains'][0]['type']).to eq('Socio cultural domain')

          # Macro meso specific
          expect(actor['short_name']).to   be_nil
          expect(actor['legal_status']).to be_nil
          expect(actor['other_names']).to  be_nil
          # Macro specific
          expect(actor['scale']).to        be_nil
        end
      end
    end

    context 'Actor details with actor and actions relations' do
      let(:actor_with_relations) do
        @location_6 = FactoryGirl.create(:localization, user: @user, start_date: Time.zone.now - 2.years, end_date: Time.zone.now - 1.year)
        @location_7 = FactoryGirl.create(:localization, user: @user, start_date: Time.zone.now - 1.years, end_date: Time.zone.now, main: true, lat: '1111111')

        relation_type = create(:actors_relation_type_belongs)
        relation_type_action = create(:act_actor_relation_type)

        action = create(:act_micro, name: 'Indicator of Department', budget: '2000', localizations: [@location_6],
                         user: @user, description: Faker::Lorem.paragraph(2, true, 4), categories: [@category_2])

        actor_with_relations = create(:actor_macro, name: 'Education Organization', user: @user,
                                       observation: Faker::Lorem.paragraph(2, true, 4), operational_field: @field, short_name: Faker::Name.name,
                                       legal_status: Faker::Name.name, other_names: Faker::Name.name,
                                       categories: [@category_1, @category_2], localizations: [@location_7])

        actor_with_relations.actor_relations_as_child  << ActorRelation.create(parent: actors[0], start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)
        actor_with_relations.actor_relations_as_parent << ActorRelation.create(child:  actors[1], start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)
        actor_with_relations.actor_relations_as_parent << ActorRelation.create(child:  actors[2], start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)
        actor_with_relations.actor_relations_as_parent << ActorRelation.create(child:  actors[3], start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)

        actor_with_relations.act_actor_relations       << ActActorRelation.create(act: action, start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type_action)
        actor_with_relations.save

        actors[3].update!(localizations: [], parent_location_id: actor_with_relations.localizations.first.id)

        actor_with_relations
      end

      get "/api/actors/:id" do
        example 'Getting a specific actor with relations' do
          do_request(id: actor_with_relations.id)
          actor = JSON.parse(response_body)['actor']

          expect(status).to eq(200)
          expect(actor['id']).to    eq(actor_with_relations.id)
          expect(actor['name']).to  eq('Education Organization')
          expect(actor['level']).to eq('macro')
          expect(actor['scale']).to match('Global')
          expect(actor['observation']).not_to  be_nil
          expect(actor['short_name']).not_to   be_nil
          expect(actor['legal_status']).not_to be_nil
          expect(actor['other_names']).not_to  be_nil

          # Relations size
          expect(actor['actors']['parents'].size).to  eq(1)
          expect(actor['actors']['children'].size).to eq(3)
          # Relations object details for parents
          expect(actor['actors']['parents'][0]['id']).not_to be_nil
          expect(actor['actors']['parents'][0]['name']).to   eq('Economy Organization')
          expect(actor['actors']['parents'][0]['level']).to  eq('macro')

          expect(actor['actors']['parents'][0]['locations'].size).to eq(2)
          expect(actor['actors']['parents'][0]['info']['start_date']).not_to be_nil
          expect(actor['actors']['parents'][0]['info']['end_date']).not_to   be_nil

          expect(actor['actors']['parents'][0]['info']['title']).to         eq('contains')
          expect(actor['actors']['parents'][0]['info']['title_reverse']).to eq('belongs to')
          # Relations object details for children
          expect(actor['actors']['children'][0]['id']).not_to be_nil
          expect(actor['actors']['children'][0]['name']).to   eq('Education Institution')
          expect(actor['actors']['children'][0]['level']).to  eq('macro')
          expect(actor['actors']['children'][1]['name']).to   eq('Department of Education')
          expect(actor['actors']['children'][1]['level']).to  eq('meso')

          expect(actor['actors']['children'][1]['locations'].size).to eq(1)
          expect(actor['actors']['children'][0]['locations'].size).to eq(1)

          # Action Relations size
          expect(actor['actions']['children'].size).to  eq(1)
          # Action Relations object details for children
          expect(actor['actions']['children'][0]['id']).not_to be_nil
          expect(actor['actions']['children'][0]['name']).to   eq('Indicator of Department')
          expect(actor['actions']['children'][0]['level']).to  eq('micro')

          expect(actor['actions']['children'][0]['locations'].size).to eq(1)

          # Get location for children from parent
          expect(actor['actors']['children'][2]['locations'].size).to eq(1)
          expect(actor['actors']['children'][2]['locations'][0]['start_date']).to eq('2014-09-01')
          expect(actor['actors']['children'][2]['locations'][0]['main']).to       eq(true)
          expect(actor['actors']['children'][2]['locations'][0]['lat']).to        eq('1111111')

          expect(actor['actors']['children'][0]['info']['start_date']).not_to be_nil
          expect(actor['actors']['children'][0]['info']['end_date']).not_to   be_nil

          expect(actor['actors']['children'][0]['info']['title']).to         eq('contains')
          expect(actor['actors']['children'][0]['info']['title_reverse']).to eq('belongs to')
        end
      end
    end
  end
end
