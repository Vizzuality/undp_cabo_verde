require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  before :each do
    @user   = create(:random_user)
    @user_2 = create(:random_user)
  end

  context "For authenticated user" do

    before :each do
      sign_in @user
    end

    it "GET root_path returns http success" do
      get :dashboard
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "GET index returns http success" do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "GET show returns http success" do
      get :show, id: @user.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "GET edit returns http success" do
      get :edit, id: @user.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "GET edit for xx user returns http success" do
      get :edit, id: @user_2.id
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
      get :show, id: @user.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

  end

end
