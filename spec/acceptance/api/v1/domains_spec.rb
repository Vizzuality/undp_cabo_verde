# encoding: UTF-8
require 'acceptance_helper'

resource 'Domains' do
  header "Accept", "application/json; application/undp-cabo-verde-v1+json"
  header "Content-Type", "application/json"
  header 'Host', 'undp-cabo-verde.herokuapp.com'

  context 'Domains API Version 1' do
    context 'Actors list' do
      let!(:categories) {
        FactoryGirl.create(:category, name: 'Category OD')
        FactoryGirl.create(:category, name: 'Category SCD', type: 'SocioCulturalDomain')
        FactoryGirl.create(:category, name: 'Category SCD 2', type: 'SocioCulturalDomain')
        FactoryGirl.create(:category, name: 'Category OD 2')
        FactoryGirl.create(:category, name: 'Derp', type: 'OrganizationType')
        FactoryGirl.create(:category, name: 'Derp2', type: 'OrganizationType')
      }
      get "/api/domains" do
        example_request 'Getting a list of domains' do
          domains = JSON.parse(response_body)['domains']

          expect(status).to eq(200)
          expect(domains.size).to eq(4)
          expect(Category.count).to eq(6)
        end
      end
    end
  end
end
