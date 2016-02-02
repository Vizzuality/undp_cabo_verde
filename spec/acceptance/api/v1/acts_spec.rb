# encoding: UTF-8
require 'acceptance_helper'

resource 'Acts' do
  header "Accept", "application/json; application/undp-cabo-verde-v1+json"
  header "Content-Type", "application/json"
  header 'Host', 'undp-cabo-verde.herokuapp.com'

  before :each do
    @user       = FactoryGirl.create(:random_user)
    @unit       = FactoryGirl.create(:unit, user: @user)
    @location   = FactoryGirl.create(:localization, user: @user)
    @location_1 = FactoryGirl.create(:localization, user: @user)
    @location_2 = FactoryGirl.create(:localization, user: @user)
    @category_1 = FactoryGirl.create(:category, name: 'Category OD')
    @category_2 = FactoryGirl.create(:category, name: 'Category SCD', type: 'SocioCulturalDomain')
  end

  context 'Acts API Version 1' do
    let!(:actions) do
      actions = []

      actions << create(:act_macro, name: 'Indicator of Organization', user: @user, localizations: [@location],
                        description: Faker::Lorem.paragraph(2, true, 4),
                        short_name: Faker::Name.name, budget: '2000',
                        alternative_name: Faker::Name.name, categories: [@category_1, @category_2])
      actions << create(:act_meso,  name: 'Indicator of Education', budget: '2000', localizations: [@location_1],
                        user: @user, description: Faker::Lorem.paragraph(2, true, 4), short_name: Faker::Name.name,
                        alternative_name: Faker::Name.name, categories: [@category_1, @category_2])
      actions << create(:act_micro, name: 'Indicator of Department', budget: '2000', localizations: [@location_2],
                        user: @user, description: Faker::Lorem.paragraph(2, true, 4), categories: [@category_2])

      actions.each do |a|
        a.touch
      end

      actions
    end

    context 'Actions list' do
      get "/api/actions" do
        example_request 'Getting a list of actions' do
          actor_1 = JSON.parse(response_body)['actions'][0]
          actor_2 = JSON.parse(response_body)['actions'][1]
          actor_3 = JSON.parse(response_body)['actions'][2]

          expect(status).to eq(200)
          expect(actor_1['level']).to eq('micro')
          expect(actor_2['level']).to eq('meso')
          expect(actor_2['name']).to  eq('Indicator of Education')
          expect(actor_3['level']).to eq('macro')
          expect(actor_3['name']).to  eq('Indicator of Organization')

          expect(actor_3['locations'][0]['lat']).not_to be_nil
          expect(actor_3['locations'].size).to         eq(1)
        end
      end

      context 'Actions list filtered by level or SCD' do
        get "/api/actions" do
          parameter :levels, 'Filter actions by level (micro, meso or macro)'
          parameter :domains_ids, 'Filter actions by socio cultural domain'

          example 'Getting a list of micro actions' do
            do_request(levels: ['micro'])
            response_actions = JSON.parse(response_body)['actions']
            expect(status).to eq(200)
            expect(response_actions.size).to eq(1)
          end

          example 'Getting a list of micro and meso actions' do
            do_request(levels: ['micro', 'meso'])
            response_actions = JSON.parse(response_body)['actions']
            expect(status).to eq(200)
            expect(response_actions.size).to eq(2)
          end

          example 'Getting a list of actions with a social cultural domain' do
            do_request(domains_ids: [@category_1.id])
            response_actions = JSON.parse(response_body)['actions']
            expect(status).to eq(200)
            expect(response_actions.size).to eq(2)
          end
        end
      end

      context 'Actions list filtered by date' do
        before :each do
          # Time.local(2015, 9, 1, 12, 0, 0, 0)
          actions[0].update_attributes(start_date: Time.zone.now - 3.years, end_date: Time.zone.now - 2.years)
          actions[1].update_attributes(start_date: Time.zone.now,           end_date: Time.zone.now + 1.year)
          actions[2].update_attributes(start_date: Time.zone.now - 1.year,  end_date: Time.zone.now)
        end

        get "/api/actions" do
          parameter :start_date, 'Filter actors by start-date (2014-01-31)'
          parameter :end_date, 'Filter actors by end-date (2015-01-31)'

          example 'Getting a list of actions by start-date' do
            do_request(start_date: '2016-01-31')
            response_actions = JSON.parse(response_body)['actions']
            expect(status).to eq(200)
            expect(response_actions.size).to eq(1)
          end

          example 'Getting a list of actions by end-date' do
            do_request(end_date: '2015-01-31')
            response_actions = JSON.parse(response_body)['actions']
            expect(status).to eq(200)
            expect(response_actions.size).to eq(2)
          end

          example 'Getting a list of actions by start-date and end-date' do
            do_request(start_date: '2012-01-31', end_date: '2015-09-30')
            response_actions = JSON.parse(response_body)['actions']
            expect(status).to eq(200)
            expect(response_actions.size).to eq(3)
          end
        end
      end
    end

    context 'Act details with actions, actors, locations' do
      let(:action_with_relations) do
        @location_3 = FactoryGirl.create(:localization, user: @user)
        @location_4 = FactoryGirl.create(:localization, user: @user)

        relation_type       = create(:acts_relation_type)
        relation_type_actor = create(:act_actor_relation_type)
        actor = create(:actor_micro, name: 'Director of Department',
                        user: @user, observation: Faker::Lorem.paragraph(2, true, 4), gender: 2,
                        title: 2, categories: [@category_2], localizations: [@location_3])

        action_with_relations = create(:act_macro, name: 'Indicator of Organization', user: @user,
                                        description: Faker::Lorem.paragraph(2, true, 4), short_name: Faker::Name.name,
                                        alternative_name: Faker::Name.name, budget: '2000',
                                        categories: [@category_1, @category_2], localizations: [@location_4])

        action_with_relations.act_relations_as_child  << ActRelation.create(parent: actions.first,  start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)
        action_with_relations.act_relations_as_parent << ActRelation.create(child:  actions.second, start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)
        action_with_relations.act_relations_as_parent << ActRelation.create(child:  actions.third,  start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)

        action_with_relations.act_actor_relations     << ActActorRelation.create(actor: actor, start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type_actor)
        action_with_relations.save

        action_with_relations
      end

      get "/api/actions/:id" do
        example 'Getting a specific action with relations' do
          do_request(id: action_with_relations.id)
          action = JSON.parse(response_body)['action']

          expect(status).to eq(200)
          expect(action['id']).to    eq(action_with_relations.id)
          expect(action['name']).to  eq('Indicator of Organization')
          expect(action['level']).to eq('macro')
          expect(action['description']).not_to  be_nil
          expect(action['short_name']).not_to   be_nil
          expect(action['alternative_name']).not_to  be_nil

          # Relations size
          expect(action['actions']['parents'].size).to  eq(1)
          expect(action['actions']['children'].size).to eq(2)
          # Relations object details for parents
          expect(action['actions']['parents'][0]['id']).not_to    be_nil
          expect(action['actions']['parents'][0]['name']).to      eq('Indicator of Organization')
          expect(action['actions']['parents'][0]['level']).to     eq('macro')

          expect(action['actions']['parents'][0]['locations'].size).to eq(1)
          expect(action['actions']['parents'][0]['info']['start_date']).not_to be_nil
          expect(action['actions']['parents'][0]['info']['end_date']).not_to   be_nil

          expect(action['actions']['parents'][0]['info']['title']).to         eq('contains')
          expect(action['actions']['parents'][0]['info']['title_reverse']).to eq('belongs to')

          # Relations object details for children
          expect(action['actions']['children'][0]['id']).not_to    be_nil
          expect(action['actions']['children'][0]['name']).to      eq('Indicator of Education')
          expect(action['actions']['children'][0]['level']).to     eq('meso')
          expect(action['actions']['children'][1]['name']).to      eq('Indicator of Department')
          expect(action['actions']['children'][1]['level']).to     eq('micro')

          expect(action['actions']['children'][1]['locations'].size).to eq(1)
          expect(action['actions']['children'][0]['locations'].size).to eq(1)
          expect(action['actions']['children'][0]['info']['start_date']).not_to be_nil
          expect(action['actions']['children'][0]['info']['end_date']).not_to   be_nil

          expect(action['actions']['children'][0]['info']['title']).to         eq('contains')
          expect(action['actions']['children'][0]['info']['title_reverse']).to eq('belongs to')

          # Actor Relations size
          expect(action['actors']['parents'].size).to  eq(1)
          # Actor Relations object details for parents
          expect(action['actors']['parents'][0]['id']).not_to    be_nil
          expect(action['actors']['parents'][0]['name']).to      eq('Director of Department')
          expect(action['actors']['parents'][0]['level']).to     eq('micro')

          expect(action['actors']['parents'][0]['locations'].size).to eq(1)
          expect(action['actors']['parents'][0]['info']['start_date']).not_to be_nil
          expect(action['actors']['parents'][0]['info']['end_date']).not_to   be_nil

          expect(action['actors']['parents'][0]['info']['title']).to         eq('implements')
          expect(action['actors']['parents'][0]['info']['title_reverse']).to eq('implemented by')
        end
      end
    end

    context 'Act details with actions, actors, locations and measurements' do
      let(:action_with_measurement) do
        relation_type_indicator = create(:act_indicator_relation_type_belongs)

        indicator = create(:indicator, name: 'Indicator one', user: @user)

        action_with_measurement = create(:act_macro, name: 'Action of Organization', user: @user,
                                          description: Faker::Lorem.paragraph(2, true, 4), short_name: Faker::Name.name,
                                          alternative_name: Faker::Name.name, budget: '2000',
                                          categories: [@category_1, @category_2], localizations: [@location])

        action_with_measurement.act_indicator_relations << ActIndicatorRelation.create(indicator: indicator, start_date: Time.zone.now - 20.days,
                                                                                       end_date: Time.zone.now, relation_type: relation_type_indicator,
                                                                                       unit: @unit, target_value: '200', deadline: Time.zone.now + 20.days)
        action_with_measurement.save

        FactoryGirl.create(:measurement, unit: @unit, date: Time.zone.now, user: @user, act_indicator_relation: action_with_measurement.act_indicator_relations.first)
        FactoryGirl.create(:measurement, unit: @unit, date: Time.zone.now, value: '300', user: @user, act_indicator_relation: action_with_measurement.act_indicator_relations.first)

        action_with_measurement
      end

      get "/api/actions/:id" do
        example 'Getting a specific action with measurements' do
          do_request(id: action_with_measurement.id)
          action = JSON.parse(response_body)['action']

          expect(status).to eq(200)
          expect(action['id']).to    eq(action_with_measurement.id)
          expect(action['name']).to  eq('Action of Organization')
          expect(action['level']).to eq('macro')

          # Relations size
          expect(action['artifacts'].size).to eq(1)
          expect(action['artifacts'][0]['measurements'].size).to eq(2)
          expect(action['artifacts'][0]['indicator']).not_to     be_nil

          # Relations object details for artifact
          expect(action['artifacts'][0]['target_value']).to   eq('200.0')
          expect(action['artifacts'][0]['unit']['name']).to   eq('Euro')
          expect(action['artifacts'][0]['unit']['symbol']).to eq('€')

          expect(action['artifacts'][0]['start_date']).to eq('2015-08-12')
          expect(action['artifacts'][0]['end_date']).to   eq('2015-09-01')
          expect(action['artifacts'][0]['deadline']).to   eq('2015-09-21')

          # Relations object details for indicator
          expect(action['artifacts'][0]['indicator']['id']).not_to be_nil
          expect(action['artifacts'][0]['indicator']['name']).to   eq('Indicator one')

          # Relations object details for measurements
          expect(action['artifacts'][0]['measurements'][1]['id']).not_to         be_nil
          expect(action['artifacts'][0]['measurements'][1]['value']).to          eq('300.0')
          expect(action['artifacts'][0]['measurements'][1]['date']).to           eq('2015-09-01')
          expect(action['artifacts'][0]['measurements'][0]['unit']['name']).to   eq('Euro')
          expect(action['artifacts'][0]['measurements'][0]['unit']['symbol']).to eq('€')
        end
      end
    end
  end
end
