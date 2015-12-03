# encoding: UTF-8
require 'acceptance_helper'

resource 'Actors' do
  header "Accept", "application/json; application/undp-cabo-verde-v1+json"
  header "Content-Type", "application/json"
  header 'Host', 'undp-cabo-verde.herokuapp.com'

  before :each do
    @user       = FactoryGirl.create(:random_user)
    @location   = FactoryGirl.create(:localization)
    @category_1 = FactoryGirl.create(:category, name: 'Category OD')
    @category_2 = FactoryGirl.create(:category, name: 'Category SCD', type: 'SocioCulturalDomain')
    @category_3 = FactoryGirl.create(:category, name: 'Category OT',  type: 'OrganizationType')
  end

  context 'Actors API Version 1' do
    let!(:actors) do
      actors = []

      actors << Actor.create(id: 1, type: 'ActorMacro', name: 'Economy Organization',    user: @user, observation: Faker::Lorem.paragraph(2, true, 4), operational_filed: 1, localizations: [@location], short_name: Faker::Name.name, legal_status: Faker::Name.name, other_names: Faker::Name.name, categories: [@category_1, @category_2, @category_3])
      actors << Actor.create(id: 2, type: 'ActorMacro', name: 'Education Institution',   user: @user, observation: Faker::Lorem.paragraph(2, true, 4), operational_filed: 2)
      actors << Actor.create(id: 3, type: 'ActorMeso',  name: 'Department of Education', user: @user, observation: Faker::Lorem.paragraph(2, true, 4), localizations: [@location], short_name: Faker::Name.name, legal_status: Faker::Name.name, other_names: Faker::Name.name, categories: [@category_1])
      actors << Actor.create(id: 4, type: 'ActorMicro', name: 'Director of Department',  user: @user, observation: Faker::Lorem.paragraph(2, true, 4), localizations: [@location], gender: 2, date_of_birth: Faker::Date.between(50.years.ago, 20.years.ago), title: 2, categories: [@category_2])
      
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
          expect(actor_1['id']).to    eq(4)
          expect(actor_1['level']).to eq('micro')
          expect(actor_2['level']).to eq('meso')
          expect(actor_3['name']).to  eq('Education Institution')
          expect(actor_3['level']).to eq('macro')
          expect(actor_4['name']).to  eq('Economy Organization')

          expect(actor_4['locations'][0]['lat']).not_to be_nil
          expect(actor_3['locations'].size).to eq(0)
        end
      end
    end

    context 'Actor details' do
      get "/api/actors/:id" do
        example 'Getting a specific actor' do
          do_request(id: 1)
          actor = JSON.parse(response_body)['actor']

          expect(status).to eq(200)
          expect(actor['id']).to    eq(1)
          expect(actor['name']).to  eq('Economy Organization')
          expect(actor['level']).to eq('macro')
          expect(actor['scale']).to eq('Global')
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

          # Micro specific
          expect(actor['title']).to         be_nil
          expect(actor['gender']).to        be_nil
          expect(actor['date_of_birth']).to be_nil

          expect(actor['organization_types'][0]['name']).to eq('Category OT')
          expect(actor['organization_types'][0]['type']).to eq('Organization type')
        end

        example 'Getting a meso actor', document: false do
          do_request(id: 3)
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
          expect(actor['date_of_birth']).to be_nil

          expect(actor['other_domains'][0]['name']).to eq('Category OD')
          expect(actor['other_domains'][0]['type']).to eq('Other domains')
        end

        example 'Getting a micro actor', document: false do
          do_request(id: 4)
          actor = JSON.parse(response_body)['actor']

          expect(status).to eq(200)
          expect(actor['level']).to  eq('micro')
          expect(actor['gender']).to eq('Male')
          expect(actor['title']).to  eq('Ms')
          expect(actor['date_of_birth']).not_to be_nil

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
  end
end