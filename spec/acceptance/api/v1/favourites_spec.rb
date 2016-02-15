# encoding: UTF-8
require 'acceptance_helper'
require 'uri'

resource 'Favourites' do
  header "Accept", "application/json; application/undp-cabo-verde-v1+json"
  header "Content-Type", "application/json"
  header 'Host', 'undp-cabo-verde.herokuapp.com'

  let!(:user) {
    user = FactoryGirl.create(:random_user, firstname: 'Favourite', lastname: 'Creator', institution: 'Vizzuality', authentication_token: '7Nw1A13xrHrZDHj631MA')
    user
  }

  let!(:user_expired) {
    user_expired = FactoryGirl.create(:random_user, firstname: 'Not Favouriteed', lastname: 'User', institution: 'Vizzuality', authentication_token: '7Nw1A13xrHrZDHj631MB')
    ActiveRecord::Base.connection.execute("UPDATE users SET token_expires_at = '#{3.years.ago}' WHERE id = #{user_expired.id}")
    user_expired
  }

  let!(:favourite) {
    favourite  = FactoryGirl.create(:favourite, name: 'Favourite one', user: user)
    favourite
  }

  get "/api/favourites" do
    parameter :token, 'User auth token'

    let!(:auth_token) { user.authentication_token }

    example 'Getting a list of user favourites', document: false do
      do_request(id: favourite.id, token: auth_token)
      favourites = JSON.parse(response_body)['favourites']
      favourite  = JSON.parse(response_body)['favourites'][0]

      expect(status).to eq(200)
      expect(favourites.size).to   eq(1)
      expect(favourite['name']).to eq('Favourite one')
      expect(favourite['uri']).to  match('http://')
      expect(favourite['date']).to match('2015-09-01T12')
    end
  end

  post "/api/favourites?name=:name&uri=:uri&token=:auth_token" do
    parameter :token, 'User auth token'
    parameter :uri,   'http://test-url.org'
    parameter :name,  'Favourite title'

    let!(:name)       { 'Favourite'                              }
    let!(:auth_token) { user.authentication_token                }
    let!(:uri)        { 'http://test-url.org/actors?active=true' }

    example_request 'Create a search favourite' do
      favourite = JSON.parse(response_body)['favourite']
      expect(status).to eq (201)
      expect(favourite['name']).to eq('Favourite')
      expect(favourite['uri']).to  eq('http://test-url.org/actors?active=true')
      expect(favourite['date']).to match('2015-09-01T12')

      expect(favourite['favorable_id']).not_to be_nil
      expect(favourite['favorable_type']).to   eq('Search')
    end
  end

  put "/api/favourites/:id?name=:new_name&token=:auth_token" do
    parameter :token, 'User auth token'
    parameter :uri,   'http://test-url.org'
    parameter :name,  'Favourite title'
    parameter :id,    'Favourite ID'

    let!(:id)         { favourite.id                             }
    let!(:new_name)   { 'Favourite new name'                     }
    let!(:auth_token) { user.authentication_token                }

    example_request 'Update name on favourite' do
      favourite = JSON.parse(response_body)['favourite']
      expect(status).to eq (201)
      expect(favourite['name']).to    eq('Favourite new name')
      expect(favourite['uri']).not_to be_nil
      expect(favourite['date']).to    match('2015-09-01T12')

      expect(favourite['favorable_id']).not_to be_nil
      expect(favourite['favorable_type']).to   eq('Search')
    end
  end

  delete "/api/favourites/:id?token=:auth_token" do
    parameter :token, 'User auth token'
    parameter :id,    'Favourite ID'

    let!(:id)         { favourite.id              }
    let!(:auth_token) { user.authentication_token }

    example_request 'Delete favourite' do
      expect(status).to eq (200)
      expect(JSON.parse(response_body)['message']).to eq('Favourite deleted')
    end
  end

  post "/api/favourites?name=:name&token=:auth_token", document: false do
    let!(:auth_token) { user.authentication_token                }
    let!(:name)       { 'Favourite'                              }

    example 'Not allow to create favourite without uri' do
      do_request
      expect(status).to eq (422)
    end
  end

  post "/api/favourites?name=:name&uri=:uri" do
    let!(:uri)        { 'http://test-url.org/actors?active=true' }
    let!(:name)       { 'Favourite'                              }

    example 'Not allow to create favourite without token', document: false do
      do_request
      expect(status).to eq (422)
    end
  end

  # Check token expiration
  context "For expired token" do
    post "/api/favourites?name=:name&uri=:uri&token=:auth_token" do
      parameter :token, 'User auth token'
      parameter :uri,   'http://test-url.org'
      parameter :name,  'Favourite title'

      let!(:name)       { 'Favourite'                               }
      let!(:uri)        { 'http://test-url.org/actors?active=true'  }
      let!(:auth_expired_token) { user_expired.authentication_token }

      example 'Not allow to create favourite with expired token', document: false do
        do_request
        expect(status).to eq(422)
        expect(JSON.parse(response_body)['message']).to eq('Please login again')
      end
    end
  end
end
