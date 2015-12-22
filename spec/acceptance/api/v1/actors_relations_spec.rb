# encoding: UTF-8
require 'acceptance_helper'

resource 'Actors Relations' do
  header "Accept", "application/json; application/undp-cabo-verde-v1+json"
  header "Content-Type", "application/json"
  header 'Host', 'undp-cabo-verde.herokuapp.com'

  before :each do
    @user       = FactoryGirl.create(:random_user)
    @category_1 = FactoryGirl.create(:category, name: 'Category OD')
    @category_2 = FactoryGirl.create(:category, name: 'Category SCD', type: 'SocioCulturalDomain')
    @field      = FactoryGirl.create(:operational_field)
  end

  context 'Actors Relations API Version 1' do
    let!(:actors) do
      actors = []
      
      actors << create(:actor_macro, name: 'Economy Organization', user: @user,
                        observation: Faker::Lorem.paragraph(2, true, 4), operational_field: @field, 
                        short_name: Faker::Name.name, legal_status: Faker::Name.name, 
                        other_names: Faker::Name.name, categories: [@category_1, @category_2])
      actors << create(:actor_meso,  name: 'Department of Education',
                        user: @user, observation: Faker::Lorem.paragraph(2, true, 4), short_name: Faker::Name.name,
                        legal_status: Faker::Name.name, other_names: Faker::Name.name, categories: [@category_1, @category_2])
      actors << create(:actor_micro, name: 'Director of Department',
                        user: @user, observation: Faker::Lorem.paragraph(2, true, 4), gender: 2,
                        title: 2, categories: [@category_2])

      actors.each do |a|
        a.touch
      end

      ActorRelation.create()

      actors
    end

    context 'Actor details with actor relations' do
      let(:actor_with_relations) do
        relation_type = create(:actors_relation_type_belongs)
        actor_with_relations = create(:actor_macro, name: 'Education Organization', user: @user,
                                   observation: Faker::Lorem.paragraph(2, true, 4), operational_field: @field, short_name: Faker::Name.name,
                                   legal_status: Faker::Name.name, other_names: Faker::Name.name,
                                   categories: [@category_1, @category_2])

        actor_with_relations.actor_relations_as_child  << ActorRelation.create(parent: actors.first,  start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)
        actor_with_relations.actor_relations_as_parent << ActorRelation.create(child:  actors.second, start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)
        actor_with_relations.actor_relations_as_parent << ActorRelation.create(child:  actors.third,  start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)
        actor_with_relations.save

        actor_with_relations
      end

      get "/api/actors/:id" do
        example 'Getting a specific actor' do
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

          # Relations count
          expect(actor['actors']['parents'].size).to  eq(1)
          expect(actor['actors']['children'].size).to eq(2)
          # Relations object details for parents
          expect(actor['actors']['parents'][0]['id']).not_to    be_nil
          expect(actor['actors']['parents'][0]['name']).to      eq('Economy Organization')
          expect(actor['actors']['parents'][0]['level']).to     eq('macro')
          expect(actor['actors']['parents'][0]['locations']).to eq([])

          expect(actor['actors']['parents_info'][0]['parent_id']).not_to  be_nil
          expect(actor['actors']['parents_info'][0]['child_id']).to       eq(actor_with_relations.id)
          expect(actor['actors']['parents_info'][0]['start_date']).not_to be_nil
          expect(actor['actors']['parents_info'][0]['end_date']).not_to   be_nil

          expect(actor['actors']['parents_info'][0]['relation_type']['title']).to         eq('contains')
          expect(actor['actors']['parents_info'][0]['relation_type']['title_reverse']).to eq('belongs to')
          # Relations object details for children
          expect(actor['actors']['children'][0]['id']).not_to    be_nil
          expect(actor['actors']['children'][0]['name']).to      eq('Department of Education')
          expect(actor['actors']['children'][0]['level']).to     eq('meso')
          expect(actor['actors']['children'][0]['locations']).to eq([])
          expect(actor['actors']['children'][1]['name']).to      eq('Director of Department')
          expect(actor['actors']['children'][1]['level']).to     eq('micro')
          expect(actor['actors']['children'][1]['locations']).to eq([])

          expect(actor['actors']['children_info'][0]['parent_id']).to      eq(actor_with_relations.id)
          expect(actor['actors']['children_info'][0]['child_id']).not_to   be_nil   
          expect(actor['actors']['children_info'][0]['start_date']).not_to be_nil
          expect(actor['actors']['children_info'][0]['end_date']).not_to   be_nil

          expect(actor['actors']['children_info'][0]['relation_type']['title']).to         eq('contains')
          expect(actor['actors']['children_info'][0]['relation_type']['title_reverse']).to eq('belongs to')
        end
      end
    end
  end
end
