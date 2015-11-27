# encoding: UTF-8
require 'acceptance_helper'

resource 'Actors' do
  header "Accept", "application/json; application/undp-cabo-verde-v1+json"
  header "Content-Type", "application/json"
  header 'Host', 'undp-cabo-verde.herokuapp.com'

  before :each do
    @user = FactoryGirl.create(:random_user)
  end

  context 'Actors API Version 1' do
    let!(:actors) do
      actors = []

      actors << Actor.create(id: 1, type: 'ActorMacro', user: @user, observation: Faker::Lorem.paragraph(2, true, 4), operational_filed: 1, name: 'Economy Organization')
      actors << Actor.create(id: 2, type: 'ActorMacro', user: @user, observation: Faker::Lorem.paragraph(2, true, 4), operational_filed: 2, name: 'Education Institution')

      actors.each do |a|
        a.touch
      end

      actors
    end
    
    context 'List json' do
      get "/api/actors" do
        example_request 'Getting a list of actors' do
          actor_1 = JSON.parse(response_body)['actors'][0]
          actor_2 = JSON.parse(response_body)['actors'][1]

          expect(status).to eq(200)
          expect(actor_1['name']).to eq('Economy Organization')
          expect(actor_2['name']).to eq('Education Institution')
        end
      end
    end

    context 'Details json' do
      get "/api/actors/:id" do
        let(:id) { actors.first.id }

        example_request 'Getting a specific actor' do
          actor = JSON.parse(response_body)['actor']

          expect(status).to eq(200)
          expect(actor['name']).to eq('Economy Organization')
        end
      end
    end
  end
end