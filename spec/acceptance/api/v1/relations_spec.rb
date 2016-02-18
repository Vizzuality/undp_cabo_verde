# encoding: UTF-8
require 'acceptance_helper'

resource 'Relations' do
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
    @field      = FactoryGirl.create(:operational_field, name: 'Global')
  end

  context 'Actors API Version 1' do
    let!(:actors) do
      actors = []

      actors << create(:actor_macro, name: 'Economy Organization', user: @user,
                        observation: Faker::Lorem.paragraph(2, true, 4), operational_field: @field,
                        localizations: [@location, @location_2], short_name: Faker::Name.name,
                        legal_status: Faker::Name.name, other_names: Faker::Name.name)
      actors << create(:actor_macro, name: 'Education Institution', localizations: [@location_3],
                        user: @user, observation: Faker::Lorem.paragraph(2, true, 4))
      actors << create(:actor_meso,  name: 'Department of Education',
                        user: @user, observation: Faker::Lorem.paragraph(2, true, 4),
                        localizations: [@location_4], short_name: Faker::Name.name,
                        legal_status: Faker::Name.name, other_names: Faker::Name.name)
      actors << create(:actor_micro, name: 'Director of Department',
                        user: @user, observation: Faker::Lorem.paragraph(2, true, 4),
                        localizations: [@location_5], gender: 2,
                        title: 2)

      actors.each do |a|
        a.touch
      end

      actors
    end

    context 'Actors list' do
      before :each do
        @location_6 = FactoryGirl.create(:localization, user: @user, start_date: Time.zone.now - 2.years, end_date: Time.zone.now - 1.year)
        @location_7 = FactoryGirl.create(:localization, user: @user, start_date: Time.zone.now - 1.years, end_date: Time.zone.now, main: true, lat: '1111111')

        relation_type = create(:actors_relation_type_belongs)
        relation_type_action = create(:act_actor_relation_type)

        action = create(:act_micro, name: 'Indicator of Department', budget: '2000', localizations: [@location_6],
                         user: @user, description: Faker::Lorem.paragraph(2, true, 4))


        actors[0].actor_relations_as_parent << ActorRelation.create(child:  actors[1], start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)
        actors[1].actor_relations_as_parent << ActorRelation.create(child:  actors[2], start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)
        actors[0].actor_relations_as_parent << ActorRelation.create(child:  actors[3], start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type)

        actors[0].act_actor_relations       << ActActorRelation.create(act: action, start_date: Time.zone.now - 20.days, end_date: Time.zone.now, relation_type: relation_type_action)
        actors[0].save

        actors[3].update!(localizations: [], parent_location_id: actors[0].localizations.first.id)
      end

      get "/api/relations" do
        example_request 'Getting a list of relations' do
          relation_1 = JSON.parse(response_body)['relations'][0]
          relation_2 = JSON.parse(response_body)['relations'][1]
          relation_3 = JSON.parse(response_body)['relations'][2]
          relation_4 = JSON.parse(response_body)['relations'][3]

          expect(status).to eq(200)
          expect(relation_1['parent_id']).to eq(actors[0].id)
          expect(relation_2['start_location']['long']).not_to be_nil
          expect(relation_3['end_location']['lat']).not_to    be_nil
          expect(relation_3['type']).to                       eq('Actor-Actor')
          expect(relation_4['end_location']['lat']).not_to    be_nil
          expect(relation_1['child_id']).to eq(actors[1].id)
          expect(relation_2['start_location']['long']).not_to be_nil
          expect(relation_3['end_location']['lat']).not_to    be_nil
          expect(relation_4['type']).to                       eq('Actor-Action')
          expect(relation_4['end_location']['lat']).not_to    be_nil
        end
      end
    end
  end
end
