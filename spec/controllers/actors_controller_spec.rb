require 'rails_helper'

RSpec.describe ActorsController, type: :controller do

  before :each do
    @user   = create(:random_user)
    @adminuser = create(:adminuser)
    FactoryGirl.create(:admin)

    @micro = create(:actor_micro, user_id: @user.id)
    @macro = create(:actor_macro, user_id: @user.id, active: false)
    @meso  = create(:actor_meso, user_id: @user.id)
  end
  
  let!(:attri) do 
    { name: 'New first', observation: 'Lorem ipsum dolor...', active: true }
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
      get :show, id: @macro.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(@macro.macro?).to eq(true)
    end

    it "GET edit returns http success" do
      get :edit, id: @micro.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(@micro.micro?).to eq(true)
    end

    it "update actor" do
      put :update, id: @meso.id, actor: attri
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@meso.meso?).to eq(true)
    end

    it "delete actor" do
      delete :destroy, id: @macro.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@macro.micro_or_meso?).to eq(false)
    end

  end

  context "Users" do

    it "GET index returns http success" do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "GET show returns http success" do
      get :show, id: @micro.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

  end

  context "AdminUser should be able to update actor" do

    before :each do
      sign_in @adminuser
    end

    it "Activate actor" do
      patch :activate, id: @macro.id, type: 'ActorMacro'
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end

    it "Deactivate actor" do
      patch :deactivate, id: @micro.id, type: 'ActorMicro'
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
      get :new, type: 'ActorMacro'
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "User should be able to create a new actor" do
      post :create, actor: {name: 'New first', observation: 'Lorem ipsum dolor...', user_id: @adminuser.id, type: 'ActorMacro'}
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@adminuser.actors.count).to eq(1)
    end

  end

end
