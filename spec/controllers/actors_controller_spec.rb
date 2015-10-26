require 'rails_helper'

RSpec.describe ActorsController, type: :controller do

  before :each do
    @user   = create(:random_user)
    @adminuser = create(:adminuser)
    FactoryGirl.create(:admin)
    @person       = create(:person, user_id: @user.id)
    @organization = create(:organization, user_id: @user.id, active: false)
  end
  
  let!(:attri) do 
    { title: 'New first', description: 'Lorem ipsum dolor...', active: true }
  end

  context "Actors for authenticated user" do

    before :each do
      sign_in @user
    end

    it "GET index returns http success" do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "GET show returns http success" do
      get :show, id: @organization.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "GET edit returns http success" do
      get :edit, id: @person.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "update actor" do
      put :update, id: @organization.id, actor: attri
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end

    it "delete actor" do
      delete :destroy, id: @organization.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end

  end

  context "Users" do

    it "GET index returns http success" do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "GET show returns http success" do
      get :show, id: @person.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

  end

  context "AdminUser should be able to update actor" do

    before :each do
      sign_in @adminuser
    end

    it "Activate actor" do
      patch :activate, id: @organization.id, type: 'Organization'
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end

    it "Deactivate actor" do
      patch :deactivate, id: @person.id, type: 'Person'
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end

  end

  context "AdminUser should be able to filter for active and inactive actors" do

    render_views

    before :each do
      sign_in @adminuser
    end

    it "Filter for active actors" do
      get :index, { active: 'true' }
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).to match('Person one')
      expect(response.body).not_to match('Organization one')
    end

    it "Filter for inactive actors" do
      get :index, { active: 'false' }
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).not_to match('Person one')
      expect(response.body).to match('Organization one')
    end

    it "GET a new actor" do
      get :new, type: 'Organization'
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "User should be able to create a new actor" do
      post :create, actor: {title: 'New first', description: 'Lorem ipsum dolor...', user_id: @adminuser.id, type: 'Organization'}
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@adminuser.actors.count).to eq(1)
    end

  end

end
