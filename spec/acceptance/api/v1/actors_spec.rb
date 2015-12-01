# encoding: UTF-8
require 'acceptance_helper'

resource 'Actors' do
  header "Accept", "application/json; application/undp-cabo-verde-v1+json"
  header "Content-Type", "application/json"
  header 'Host', 'undp-cabo-verde.herokuapp.com'

  before :each do
    @user     = FactoryGirl.create(:random_user)
    @location = FactoryGirl.create(:localization)
  end

  context 'Actors API Version 1' do
    let!(:actors) do
      actors = []

      actors << Actor.create(id: 1, type: 'ActorMacro', name: 'Economy Organization',  user: @user, observation: Faker::Lorem.paragraph(2, true, 4), operational_filed: 1, localizations: [@location])
      actors << Actor.create(id: 2, type: 'ActorMacro', name: 'Education Institution', user: @user, observation: Faker::Lorem.paragraph(2, true, 4), operational_filed: 2)

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

          expect(status).to eq(200)
          expect(actor_1['name']).to  eq('Education Institution')
          expect(actor_1['level']).to eq('ActorMacro')
          expect(actor_2['name']).to  eq('Economy Organization')

          expect(actor_2['locations'][0]['lat']).not_to be_nil
          expect(actor_1['locations'].size).to eq(0)
        end
      end
    end

    context 'Actor details' do
      get "/api/actors/:id" do
        let(:id) { 1 }

        example_request 'Getting a specific actor' do
          actor = JSON.parse(response_body)['actor']

          expect(status).to eq(200)
          expect(actor['name']).to  eq('Economy Organization')
          expect(actor['level']).to eq('ActorMacro')
          
          expect(actor['locations'][0]['lat']).not_to  be_nil
          expect(actor['locations'][0]['long']).not_to be_nil
        end
      end
    end
  end
end