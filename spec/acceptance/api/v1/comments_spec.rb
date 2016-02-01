# encoding: UTF-8
require 'acceptance_helper'

resource 'Comments' do
  header "Accept", "application/json; application/undp-cabo-verde-v1+json"
  header "Content-Type", "application/json"
  header 'Host', 'undp-cabo-verde.herokuapp.com'

  let!(:user) {
    user = FactoryGirl.create(:random_user, firstname: 'Comment', lastname: 'Creator', institution: 'Vizzuality', authentication_token: '7Nw1A13xrHrZDHj631MA')
    user
  }

  let!(:user_2) {
    user_2 = FactoryGirl.create(:user, firstname: 'Commented', lastname: 'User', institution: 'Vizzuality')
    user_2
  }

  let!(:user_expired) {
    user_expired = FactoryGirl.create(:random_user, firstname: 'Not Commented', lastname: 'User', institution: 'Vizzuality', authentication_token: '7Nw1A13xrHrZDHj631MB')
    ActiveRecord::Base.connection.execute("UPDATE users SET token_expires_at = '#{3.years.ago}' WHERE id = #{user_expired.id}")
    user_expired
  }

  get "/api/actors/:id" do
    let!(:actor) {
      actor  = FactoryGirl.create(:actor_meso, name: 'Economy Organization', user: user,
                                   comments: [FactoryGirl.create(:comment, user: user_2,
                                   body: 'Test comment on actor')])
      actor
    }

    example 'Getting an actor with comment', document: false do
      do_request(id: actor.id)
      actor = JSON.parse(response_body)['actor']

      expect(status).to eq(200)
      expect(actor['level']).to eq('meso')
      expect(actor['comments'].size).to       eq(1)
      expect(actor['comments'][0]['body']).to eq('Test comment on actor')
      expect(actor['comments'][0]['date']).to match('2015-09-01T12')
      # Comments user
      expect(actor['comments'][0]['user']['firstname']).to   eq('Commented')
      expect(actor['comments'][0]['user']['lastname']).to    eq('User')
      expect(actor['comments'][0]['user']['institution']).to eq('Vizzuality')
    end
  end

  get "/api/actions/:id" do
    let!(:action) {
      action = FactoryGirl.create(:act_meso, name: 'Economy project', user: user_2,
                                   comments: [FactoryGirl.create(:comment, user: user_2,
                                   body: 'Test comment on action')])
      action
    }

    example 'Getting an action with comment', document: false do
      do_request(id: action.id)
      action = JSON.parse(response_body)['action']

      expect(status).to eq(200)
      expect(action['level']).to eq('meso')
      expect(action['comments'].size).to       eq(1)
      expect(action['comments'][0]['body']).to eq('Test comment on action')
      expect(action['comments'][0]['date']).to match('2015-09-01T12')
      # Comments user
      expect(action['comments'][0]['user']['firstname']).to   eq('Commented')
      expect(action['comments'][0]['user']['lastname']).to    eq('User')
      expect(action['comments'][0]['user']['institution']).to eq('Vizzuality')
    end
  end

  get "/api/artifacts/:id" do
    let!(:artifact) {
      artifact  = FactoryGirl.create(:indicator, name: 'Economy indicator', user: user,
                                      comments: [FactoryGirl.create(:comment, user: user_2,
                                      body: 'Test comment on artifact')])
      artifact
    }

    example 'Getting an artifact with comment', document: false do
      do_request(id: artifact.id)
      artifact = JSON.parse(response_body)['artifact']

      expect(status).to eq(200)
      expect(artifact['comments'].size).to       eq(1)
      expect(artifact['comments'][0]['body']).to eq('Test comment on artifact')
      expect(artifact['comments'][0]['date']).to match('2015-09-01T12')
      # Comments user
      expect(artifact['comments'][0]['user']['firstname']).to   eq('Commented')
      expect(artifact['comments'][0]['user']['lastname']).to    eq('User')
      expect(artifact['comments'][0]['user']['institution']).to eq('Vizzuality')
    end
  end

  # Actors
  let!(:actor) {
    actor  = FactoryGirl.create(:actor_meso, name: 'Economy Organization', user: user,
                                 comments: [FactoryGirl.create(:comment, user: user_2,
                                 body: 'Test comment on actor')])
    actor
  }

  get "/api/actors/:id/comments" do
    parameter :id, 'Actor id'

    let!(:id) { actor.id }

    example_request 'Getting a comments list for actor' do
      expect(status).to eq(200)
      expect(JSON.parse(response_body)['comments'].size).to       eq(1)
      expect(JSON.parse(response_body)['comments'][0]['body']).to eq('Test comment on actor')
      expect(JSON.parse(response_body)['comments'][0]['date']).to match('2015-09-01T12')
      # Comments user
      expect(JSON.parse(response_body)['comments'][0]['user']['firstname']).to   eq('Commented')
      expect(JSON.parse(response_body)['comments'][0]['user']['lastname']).to    eq('User')
      expect(JSON.parse(response_body)['comments'][0]['user']['institution']).to eq('Vizzuality')
    end
  end

  post "/api/actors/:id/comments?token=:auth_token&body=:body" do
    parameter :id, 'Actor id'
    parameter :token, 'User auth token'
    parameter :body, 'Comment text'

    let!(:id)   { actor.id             }
    let!(:body) { 'My created comment' }
    let!(:auth_token) { user.authentication_token }

    example_request 'Create comment on actor' do
      expect(status).to eq (201)
      expect(JSON.parse(response_body)['comment']['body']).to eq('My created comment')
      expect(JSON.parse(response_body)['comment']['date']).to match('2015-09-01T12')
      # Actor info
      expect(JSON.parse(response_body)['comment']['commentable_type']).to eq('Actor')
      expect(JSON.parse(response_body)['comment']['commentable_id']).to   eq(actor.id)
      # Comments user
      expect(JSON.parse(response_body)['comment']['user']['firstname']).to   eq('Comment')
      expect(JSON.parse(response_body)['comment']['user']['lastname']).to    eq('Creator')
      expect(JSON.parse(response_body)['comment']['user']['institution']).to eq('Vizzuality')
    end
  end

  post "/api/actors/:id/comments?token=:auth_token" do
    parameter :id, 'Actor id'
    parameter :token, 'User auth token'

    let!(:id)   { actor.id             }
    let!(:auth_token) { user.authentication_token }

    example 'Not allow to create actor comment without body', document: false do
      do_request
      expect(status).to eq (422)
    end
  end

  post "/api/actors/:id/comments?body=:body" do
    parameter :id, 'Actor id'
    parameter :body, 'Comment text'

    let!(:id)   { actor.id             }
    let!(:body) { 'Text comment'       }

    example 'Not allow to create actor comment without token', document: false do
      do_request
      expect(status).to eq (422)
    end
  end

  # Check token expiration
  context "For expired token" do
    post "/api/actors/:id/comments?token=:auth_expired_token&body=:body" do
      parameter :id, 'Actor id'
      parameter :token, 'User auth token'
      parameter :body, 'Comment text'

      let!(:auth_expired_token) { user_expired.authentication_token }
      let!(:body) { 'Not created comment' }
      let!(:id)   { actor.id              }

      example 'Not allow to create actor comment with expired token', document: false do
        do_request
        expect(status).to eq(422)
        expect(JSON.parse(response_body)['message']).to eq('Please login again')
      end
    end
  end

  # Actions
  let!(:action) {
    action = FactoryGirl.create(:act_meso, name: 'Economy project', user: user_2,
                                 comments: [FactoryGirl.create(:comment, user: user_2,
                                 body: 'Test comment on action')])
    action
  }

  get "/api/actions/:id/comments" do
    parameter :id, 'Action id'

    let!(:id) { action.id }

    example_request 'Getting a comments list for action' do
      expect(status).to eq(200)
      expect(JSON.parse(response_body)['comments'].size).to       eq(1)
      expect(JSON.parse(response_body)['comments'][0]['body']).to eq('Test comment on action')
      expect(JSON.parse(response_body)['comments'][0]['date']).to match('2015-09-01T12')
      # Comments user
      expect(JSON.parse(response_body)['comments'][0]['user']['firstname']).to   eq('Commented')
      expect(JSON.parse(response_body)['comments'][0]['user']['lastname']).to    eq('User')
      expect(JSON.parse(response_body)['comments'][0]['user']['institution']).to eq('Vizzuality')
    end
  end

  post "/api/actions/:id/comments?token=:auth_token&body=:body" do
    parameter :id, 'Action id'
    parameter :token, 'User auth token'
    parameter :body, 'Comment text'

    let!(:id)   { action.id            }
    let!(:body) { 'My created comment' }

    let!(:auth_token) {
      user.authentication_token
    }

    example_request 'Create comment on action' do
      expect(status).to eq (201)
      expect(JSON.parse(response_body)['comment']['body']).to eq('My created comment')
      expect(JSON.parse(response_body)['comment']['date']).to match('2015-09-01T12')
      # Actor info
      expect(JSON.parse(response_body)['comment']['commentable_type']).to eq('Act')
      expect(JSON.parse(response_body)['comment']['commentable_id']).to   eq(action.id)
      # Comments user
      expect(JSON.parse(response_body)['comment']['user']['firstname']).to   eq('Comment')
      expect(JSON.parse(response_body)['comment']['user']['lastname']).to    eq('Creator')
      expect(JSON.parse(response_body)['comment']['user']['institution']).to eq('Vizzuality')
    end
  end

  post "/api/actions/:id/comments?token=:auth_token" do
    example 'Not allow to create action without body', document: false do
      do_request
      expect(status).to eq (422)
    end
  end

  post "/api/actions/:id/comments?body=:body" do
    example 'Not allow to create action without token', document: false do
      do_request
      expect(status).to eq (422)
    end
  end

  # Artifacts
  let!(:artifact) {
    artifact = FactoryGirl.create(:indicator, name: 'Economy indicator', user: user_2,
                                   comments: [FactoryGirl.create(:comment, user: user_2,
                                   body: 'Test comment on artifact')])
    artifact
  }

  get "/api/artifacts/:id/comments" do
    parameter :id, 'Artifact id'

    let!(:id) { artifact.id }

    example_request 'Getting a comments list for artifact' do
      expect(status).to eq(200)
      expect(JSON.parse(response_body)['comments'].size).to       eq(1)
      expect(JSON.parse(response_body)['comments'][0]['body']).to eq('Test comment on artifact')
      expect(JSON.parse(response_body)['comments'][0]['date']).to match('2015-09-01T12')
      # Comments user
      expect(JSON.parse(response_body)['comments'][0]['user']['firstname']).to   eq('Commented')
      expect(JSON.parse(response_body)['comments'][0]['user']['lastname']).to    eq('User')
      expect(JSON.parse(response_body)['comments'][0]['user']['institution']).to eq('Vizzuality')
    end
  end

  post "/api/artifacts/:id/comments?token=:auth_token&body=:body" do
    parameter :id, 'Artifact id'
    parameter :token, 'User auth token'
    parameter :body, 'Comment text'

    let!(:id)   { artifact.id            }
    let!(:body) { 'My created comment' }

    let!(:auth_token) {
      user.authentication_token
    }

    example_request 'Create comment on artifact' do
      expect(status).to eq (201)
      expect(JSON.parse(response_body)['comment']['body']).to eq('My created comment')
      expect(JSON.parse(response_body)['comment']['date']).to match('2015-09-01T12')
      # Actor info
      expect(JSON.parse(response_body)['comment']['commentable_type']).to eq('Indicator')
      expect(JSON.parse(response_body)['comment']['commentable_id']).to   eq(artifact.id)
      # Comments user
      expect(JSON.parse(response_body)['comment']['user']['firstname']).to   eq('Comment')
      expect(JSON.parse(response_body)['comment']['user']['lastname']).to    eq('Creator')
      expect(JSON.parse(response_body)['comment']['user']['institution']).to eq('Vizzuality')
    end
  end

  post "/api/artifacts/:id/comments?token=:auth_token" do
    example 'Not allow to create artifact without body', document: false do
      do_request
      expect(status).to eq (422)
    end
  end

  post "/api/artifacts/:id/comments?body=:body" do
    example 'Not allow to create artifact without token', document: false do
      do_request
      expect(status).to eq (422)
    end
  end
end
