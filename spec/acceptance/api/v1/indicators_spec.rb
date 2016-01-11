# encoding: UTF-8
require 'acceptance_helper'

resource 'Artifacts' do
  header "Accept", "application/json; application/undp-cabo-verde-v1+json"
  header "Content-Type", "application/json"
  header 'Host', 'undp-cabo-verde.herokuapp.com'

  before :each do
    @user       = FactoryGirl.create(:random_user)
    @category_1 = FactoryGirl.create(:category, name: 'Category OD')
    @category_2 = FactoryGirl.create(:category, name: 'Category SCD', type: 'SocioCulturalDomain')
  end

  context 'Artifacts API Version 1' do
    let!(:artifacts) do
      artifacts = []
      
      artifacts << create(:indicator, name: 'Indicator of Organization', user: @user, alternative_name: Faker::Name.name, categories: [@category_1, @category_2])
      artifacts << create(:indicator, name: 'Indicator of Project', user: @user, alternative_name: Faker::Name.name, categories: [@category_2])
      artifacts << create(:indicator, name: 'Indicator of Department', user: @user, alternative_name: Faker::Name.name, categories: [@category_1])

      artifacts.each do |a|
        a.touch
      end

      artifacts
    end

    context 'Artifacts list' do
      get "/api/artifacts" do
        example_request 'Getting a list of artifacts' do
          indicator_1 = JSON.parse(response_body)['artifacts'][0]
          indicator_2 = JSON.parse(response_body)['artifacts'][1]
          indicator_3 = JSON.parse(response_body)['artifacts'][2]

          expect(status).to eq(200)
          expect(indicator_2['name']).to eq('Indicator of Project')
          expect(indicator_3['name']).to eq('Indicator of Organization')
        end
      end
    end

    context 'Artifact details with actions' do
      let(:indicator_with_action) do
        relation_type_indicator = create(:act_indicator_relation_type_belongs)
        location                = create(:localization, user: @user)
        unit                    = create(:unit, user: @user)

        indicator_with_action = Indicator.first

        action = create(:act_macro, name: 'Action of Organization', user: @user,
                                    description: Faker::Lorem.paragraph(2, true, 4), short_name: Faker::Name.name,
                                    alternative_name: Faker::Name.name, budget: '2000',
                                    categories: [@category_1, @category_2], localizations: [location])

        indicator_with_action.act_indicator_relations << ActIndicatorRelation.create(act: action, start_date: Time.zone.now - 20.days, 
                                                                                       end_date: Time.zone.now, relation_type: relation_type_indicator,
                                                                                       unit: unit, target_value: '200', deadline: Time.zone.now + 20.days)

        indicator_with_action
      end

      get "/api/artifacts/:id" do
        example 'Getting a specific artifact with actions' do
          do_request(id: indicator_with_action.id)
          artifact = JSON.parse(response_body)['artifact']

          expect(status).to eq(200)
          expect(artifact['id']).to    eq(indicator_with_action.id)
          expect(artifact['name']).to  eq('Indicator of Organization')
          expect(artifact['alternative_name']).not_to be_nil

          # Relations with actions
          expect(artifact['actions'][0]['id']).not_to be_nil
          expect(artifact['actions'][0]['level']).to  eq('macro')
          expect(artifact['actions'][0]['name']).to   eq('Action of Organization')
          expect(artifact['actions'][0]['locations'].count).to eq(1)
        end
      end
    end
  end
end
