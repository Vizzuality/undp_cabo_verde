# encoding: UTF-8
require 'acceptance_helper'

resource 'Actors' do
  header "Accept", "application/json; application/undp-cabo-verde-v1+json"
  header "Content-Type", "application/json"
  header 'Host', 'undp-cabo-verde.herokuapp.com'

  before :each do
    @user       = FactoryGirl.create(:random_user)
    @location   = FactoryGirl.create(:localization, user: @user)
    @category_1 = FactoryGirl.create(:category, name: 'Category OD')
    @category_2 = FactoryGirl.create(:category, name: 'Category SCD', type: 'SocioCulturalDomain')
    @category_3 = FactoryGirl.create(:category, name: 'Category OT',  type: 'OrganizationType')
    @field      = FactoryGirl.create(:operational_field)
  end

  context 'Actors API Version 1' do
    let!(:actors) do
      actors = []

      actors << create(:actor_macro, name: 'Economy Organization', user: @user,
                        observation: Faker::Lorem.paragraph(2, true, 4), operational_field: @field,
                        localizations: [@location], short_name: Faker::Name.name,
                        legal_status: Faker::Name.name, other_names: Faker::Name.name,
                        categories: [@category_1, @category_2, @category_3])
      actors << create(:actor_macro, name: 'Education Institution', localizations: [@location],
                        user: @user, observation: Faker::Lorem.paragraph(2, true, 4), categories: [@category_2])
      actors << create(:actor_meso,  name: 'Department of Education',
                        user: @user, observation: Faker::Lorem.paragraph(2, true, 4),
                        localizations: [@location], short_name: Faker::Name.name,
                        legal_status: Faker::Name.name, other_names: Faker::Name.name, categories: [@category_1, @category_2])
      actors << create(:actor_micro, name: 'Director of Department',
                        user: @user, observation: Faker::Lorem.paragraph(2, true, 4),
                        localizations: [@location], gender: 2,
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
          expect(actor_3['locations'].size).to eq(1)
        end

        example_request 'Getting a list of micro actors' do
          do_request(levels: ['micro'])
          response_actors = JSON.parse(response_body)['actors']
          expect(status).to eq(200)
          expect(response_actors.size).to eq(1)
        end

        example_request 'Getting a list of micro and meso actors' do
          do_request(levels: ['micro', 'meso'])
          response_actors = JSON.parse(response_body)['actors']
          expect(status).to eq(200)
          expect(response_actors.size).to eq(2)
        end

        example_request 'Getting a list of actors with a social cultural domain' do
          do_request(domains_ids: [@category_1.id])
          response_actors = JSON.parse(response_body)['actors']
          expect(status).to eq(200)
          expect(response_actors.size).to eq(2)
        end
      end
    end

    context 'Actor details' do
      get "/api/actors/:id" do
        example 'Getting a specific actor with locations' do
          do_request(id: actors.first.id)
          actor = JSON.parse(response_body)['actor']

          expect(status).to eq(200)
          expect(actor['id']).to    eq(actors.first.id)
          expect(actor['name']).to  eq('Economy Organization')
          expect(actor['level']).to eq('macro')
          expect(actor['scale']).to eq('Global')
          expect(actor['observation']).not_to              be_nil
          expect(actor['short_name']).not_to               be_nil
          expect(actor['legal_status']).not_to             be_nil
          expect(actor['other_names']).not_to              be_nil
          expect(actor['locations'][0]['info_data']['name']).not_to     be_nil
          expect(actor['locations'][0]['info_data']['country']).not_to  be_nil
          expect(actor['locations'][0]['info_data']['city']).not_to     be_nil
          expect(actor['locations'][0]['info_data']['zip_code']).not_to be_nil
          expect(actor['locations'][0]['info_data']['state']).not_to    be_nil
          expect(actor['locations'][0]['info_data']['district']).not_to be_nil
          expect(actor['locations'][0]['info_data']['web_url']).not_to  be_nil
          expect(actor['locations'][0]['info_data']['lat']).not_to      be_nil
          expect(actor['locations'][0]['info_data']['long']).not_to     be_nil

          # Micro specific
          expect(actor['title']).to         be_nil
          expect(actor['gender']).to        be_nil

          expect(actor['organization_types'][0]['name']).to eq('Category OT')
          expect(actor['organization_types'][0]['type']).to eq('Organization type')
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
          expect(actor['scale']).to         be_nil
          # Micro specific
          expect(actor['title']).to         be_nil
          expect(actor['gender']).to        be_nil

          expect(actor['other_domains'][0]['name']).to eq('Category OD')
          expect(actor['other_domains'][0]['type']).to eq('Other domains')
        end

        example 'Getting a micro actor', document: false do
          do_request(id: actors[3].id)
          actor = JSON.parse(response_body)['actor']

          expect(status).to eq(200)
          expect(actor['level']).to  eq('micro')
          expect(actor['gender']).to eq('Male')
          expect(actor['title']).to  eq('Ms.')

          expect(actor['socio_cultural_domains'][0]['name']).to eq('Category SCD')
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
        relation_type = create(:actors_relation_type_belongs)
        relation_type_action = create(:act_actor_relation_type)

        action = create(:act_micro, name: 'Indicator of Department', budget: '2000', localizations: [@location],
                        user: @user, description: Faker::Lorem.paragraph(2, true, 4), categories: [@category_2])

        actor_with_relations = create(:actor_macro, name: 'Education Organization', user: @user,
                                   observation: Faker::Lorem.paragraph(2, true, 4), operational_field: @field, short_name: Faker::Name.name,
                                   legal_status: Faker::Name.name, other_names: Faker::Name.name,
                                   categories: [@category_1, @category_2])

        actor_with_relations.actor_relations_as_child  << ActorRelation.create(parent: actors.first,  start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)
        actor_with_relations.actor_relations_as_parent << ActorRelation.create(child:  actors.second, start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)
        actor_with_relations.actor_relations_as_parent << ActorRelation.create(child:  actors.third,  start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)

        actor_with_relations.act_actor_relations       << ActActorRelation.create(act: action, start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type_action)
        actor_with_relations.save

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
          expect(actor['scale']).to eq('Global')
          expect(actor['observation']).not_to  be_nil
          expect(actor['short_name']).not_to   be_nil
          expect(actor['legal_status']).not_to be_nil
          expect(actor['other_names']).not_to  be_nil

          # Relations size
          expect(actor['actors']['parents'].size).to  eq(1)
          expect(actor['actors']['children'].size).to eq(2)
          # Relations object details for parents
          expect(actor['actors']['parents'][0]['id']).not_to    be_nil
          expect(actor['actors']['parents'][0]['name']).to      eq('Economy Organization')
          expect(actor['actors']['parents'][0]['level']).to     eq('macro')

          expect(actor['actors']['parents'][0]['locations'].size).to eq(1)

          expect(actor['actors']['parents_info'][0]['parent_id']).not_to  be_nil
          expect(actor['actors']['parents_info'][0]['child_id']).to       eq(actor_with_relations.id)
          expect(actor['actors']['parents_info'][0]['start_date']).not_to be_nil
          expect(actor['actors']['parents_info'][0]['end_date']).not_to   be_nil

          expect(actor['actors']['parents_info'][0]['relation_type']['title']).to         eq('contains')
          expect(actor['actors']['parents_info'][0]['relation_type']['title_reverse']).to eq('belongs to')
          # Relations object details for children
          expect(actor['actors']['children'][0]['id']).not_to    be_nil
          expect(actor['actors']['children'][0]['name']).to      eq('Education Institution')
          expect(actor['actors']['children'][0]['level']).to     eq('macro')
          expect(actor['actors']['children'][1]['name']).to      eq('Department of Education')
          expect(actor['actors']['children'][1]['level']).to     eq('meso')

          expect(actor['actors']['children'][1]['locations'].size).to eq(1)
          expect(actor['actors']['children'][0]['locations'].size).to eq(1)

          expect(actor['actors']['children_info'][0]['parent_id']).to      eq(actor_with_relations.id)
          expect(actor['actors']['children_info'][0]['child_id']).not_to   be_nil   
          expect(actor['actors']['children_info'][0]['start_date']).not_to be_nil
          expect(actor['actors']['children_info'][0]['end_date']).not_to   be_nil

          expect(actor['actors']['children_info'][0]['relation_type']['title']).to         eq('contains')
          expect(actor['actors']['children_info'][0]['relation_type']['title_reverse']).to eq('belongs to')

          # Action Relations size
          expect(actor['actions']['children'].size).to  eq(1)
          # Action Relations object details for children
          expect(actor['actions']['children'][0]['id']).not_to    be_nil
          expect(actor['actions']['children'][0]['name']).to      eq('Indicator of Department')
          expect(actor['actions']['children'][0]['level']).to     eq('micro')

          expect(actor['actions']['children'][0]['locations'].size).to eq(1)

          expect(actor['actions']['children_info'][0]['act_id']).to   eq(Act.last.id)
          expect(actor['actions']['children_info'][0]['actor_id']).to     eq(actor_with_relations.id)
          expect(actor['actions']['children_info'][0]['start_date']).to eq('2015-08-12')
          expect(actor['actions']['children_info'][0]['end_date']).to   eq('2015-09-01')

          expect(actor['actions']['children_info'][0]['relation_type']['title']).to         eq('implements')
          expect(actor['actions']['children_info'][0]['relation_type']['title_reverse']).to eq('implemented by')
        end
      end
    end
  end
end
