require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before :each do
    @user   = create(:random_user)
    @user_2 = create(:user, active: false)
    @user_3 = create(:random_public_user)
    @adminuser = create(:adminuser)
    FactoryGirl.create(:admin)
  end

  let!(:attri) do
    { firstname: 'newfirst', lastname: 'newlast' }
  end

  let!(:attri_fail) do
    { email: '' }
  end

  context 'For authenticated user' do
    before :each do
      sign_in @user
    end

    it 'GET root_path returns http success' do
      get :dashboard
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'GET index returns http success' do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'GET show returns http success' do
      get :show, id: @user.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'GET edit returns http success' do
      get :edit, id: @user.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'GET edit for xx user returns http redirect' do
      get :edit, id: @user_2.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end

    it 'update user' do
      put :update, id: @user.id, user: attri
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end

    render_views

    it 'User should not be able to update user without email' do
      put :update, id: @user.id, user: attri_fail
      expect(response.body).to match('<small class="error">can&#39;t be blank</small>')
    end
  end

  context 'Users' do
    it 'GET index returns http redirect for non logged in user' do
      get :index
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end

    it 'GET show returns http redirect for non logged in user' do
      get :show, id: @user.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end
  end

  context 'AdminUser should be able to activate and deactivate user' do
    before :each do
      sign_in @adminuser
    end

    it 'Activate user' do
      patch :activate, id: @user_2.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end

    it 'Deactivate user' do
      patch :deactivate, id: @user.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end
  end

  context 'AdminUser should be able to filter for active and inactive user' do
    render_views

    before :each do
      sign_in @adminuser
    end

    it 'Filter for active users' do
      get :index, { active: 'true' }
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).to match('Random User')
      expect(response.body).to match('Juanito Lolito')
      expect(response.body).not_to match('Pepe Moreno')
    end

    it 'Filter for inactive users' do
      get :index, { active: 'false' }
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).not_to match('Random User')
      expect(response.body).to match('Pepe Moreno')
    end
  end

  context 'AdminUser should be able to set up roles for user' do
    before :each do
      @adminuser_2 = create(:random_adminuser)
      FactoryGirl.create(:admin_2)
      sign_in @adminuser
    end

    it 'Make user admin' do
      patch :make_admin, id: @user_2.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@user_2.admin?).to eq(true)
    end

    it 'Make user manager' do
      patch :make_manager, id: @user_3.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@user_2.manager?).to eq(true)
    end

    it 'Revoke admin role for user' do
      expect(@adminuser_2.admin?).to eq(true)
      patch :make_user, id: @adminuser_2.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@adminuser_2.reload.admin?).to eq(false)
    end

    it 'Revoke manager role for user' do
      expect(@user_2.manager?).to eq(true)
      patch :make_user, id: @user_2.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@user_2.reload.manager?).to eq(false)
    end
  end
end
