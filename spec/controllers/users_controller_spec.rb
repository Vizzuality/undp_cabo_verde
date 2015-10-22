require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  before :each do
    @user = create(:user)
    @user_deactivated = create(:user).deactivate
  end

  context "Homepage for authenticated user" do

    before :each do
      sign_in @user
    end

    it "GET root_path returns http success" do
      get :dashboard
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "Deactivate user" do
      get :deactivate, id: @user.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      @user.deactivated?
      @user.deactivated_at == Time.now
    end

  end

  context "Users" do

    it "GET index returns http success" do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "GET deactivated users" do
      @users = User.filter_inactives
      get :index, active: false
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(@users.size).to eq(1)
    end

    it "GET show returns http success" do
      get :show, id: @user.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

  end

end
