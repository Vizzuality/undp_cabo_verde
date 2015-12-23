# encoding: UTF-8
require 'acceptance_helper'

resource 'Acts' do
  header "Accept", "application/json; application/undp-cabo-verde-v1+json"
  header "Content-Type", "application/json"
  header 'Host', 'undp-cabo-verde.herokuapp.com'

  before :each do
    @user       = FactoryGirl.create(:random_user)
    @location   = FactoryGirl.create(:localization, user: @user)
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
      actions << create(:act_meso,  name: 'Indicator of Education', budget: '2000', localizations: [@location],
                        user: @user, description: Faker::Lorem.paragraph(2, true, 4), short_name: Faker::Name.name, 
                        alternative_name: Faker::Name.name, categories: [@category_1, @category_2])
      actions << create(:act_micro, name: 'Indicator of Department', budget: '2000', localizations: [@location],
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
    end

    context 'Act details with action and actors relations' do
      let(:action_with_relations) do
        relation_type       = create(:acts_relation_type)
        relation_type_actor = create(:act_actor_relation_type)
        actor = create(:actor_micro, name: 'Director of Department',
                        user: @user, observation: Faker::Lorem.paragraph(2, true, 4), gender: 2,
                        title: 2, categories: [@category_2], localizations: [@location])

        action_with_relations = create(:act_macro, name: 'Indicator of Organization', user: @user,
                                   description: Faker::Lorem.paragraph(2, true, 4), short_name: Faker::Name.name,
                                   alternative_name: Faker::Name.name, budget: '2000',
                                   categories: [@category_1, @category_2], localizations: [@location])

        action_with_relations.act_relations_as_child  << ActRelation.create(parent: actions.first,  start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)
        action_with_relations.act_relations_as_parent << ActRelation.create(child:  actions.second, start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)
        action_with_relations.act_relations_as_parent << ActRelation.create(child:  actions.third,  start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)

        action_with_relations.act_actor_relations     << ActActorRelation.create(actor: actor, start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type_actor)
        action_with_relations.save

        action_with_relations
      end

      get "/api/actions/:id" do
        example 'Getting a specific action' do
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

          expect(action['actions']['parents_info'][0]['parent_id']).not_to  be_nil
          expect(action['actions']['parents_info'][0]['child_id']).to       eq(action_with_relations.id)
          expect(action['actions']['parents_info'][0]['start_date']).not_to be_nil
          expect(action['actions']['parents_info'][0]['end_date']).not_to   be_nil

          expect(action['actions']['parents_info'][0]['relation_type']['title']).to         eq('contains')
          expect(action['actions']['parents_info'][0]['relation_type']['title_reverse']).to eq('belongs to')
          # Relations object details for children
          expect(action['actions']['children'][0]['id']).not_to    be_nil
          expect(action['actions']['children'][0]['name']).to      eq('Indicator of Education')
          expect(action['actions']['children'][0]['level']).to     eq('meso')
          expect(action['actions']['children'][1]['name']).to      eq('Indicator of Department')
          expect(action['actions']['children'][1]['level']).to     eq('micro')

          expect(action['actions']['children'][1]['locations'].size).to eq(1)
          expect(action['actions']['children'][0]['locations'].size).to eq(1)

          expect(action['actions']['children_info'][0]['parent_id']).to      eq(action_with_relations.id)
          expect(action['actions']['children_info'][0]['child_id']).not_to   be_nil   
          expect(action['actions']['children_info'][0]['start_date']).not_to be_nil
          expect(action['actions']['children_info'][0]['end_date']).not_to   be_nil

          expect(action['actions']['children_info'][0]['relation_type']['title']).to         eq('contains')
          expect(action['actions']['children_info'][0]['relation_type']['title_reverse']).to eq('belongs to')

          # Actor Relations size
          expect(action['actors']['parents'].size).to  eq(1)
          # Actor Relations object details for parents
          expect(action['actors']['parents'][0]['id']).not_to    be_nil
          expect(action['actors']['parents'][0]['name']).to      eq('Director of Department')
          expect(action['actors']['parents'][0]['level']).to     eq('micro')

          expect(action['actors']['parents'][0]['locations'].size).to eq(1)

          expect(action['actors']['parents_info'][0]['actor_id']).to   eq(Actor.last.id)
          expect(action['actors']['parents_info'][0]['act_id']).to     eq(action_with_relations.id)
          expect(action['actors']['parents_info'][0]['start_date']).to eq('2015-08-12')
          expect(action['actors']['parents_info'][0]['end_date']).to   eq('2015-09-01')

          expect(action['actors']['parents_info'][0]['relation_type']['title']).to         eq('implements')
          expect(action['actors']['parents_info'][0]['relation_type']['title_reverse']).to eq('implemented by')
        end
      end
    end
  end
end
