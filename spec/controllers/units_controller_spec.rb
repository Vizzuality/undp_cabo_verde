require 'rails_helper'

RSpec.describe UnitsController, type: :controller do
  before :each do
    @user      = create(:random_user)
    @adminuser = create(:adminuser)
    FactoryGirl.create(:admin)

    @unit = create(:unit, user: @user)
  end

  let!(:attri) do
    { name: 'Dolar', symbol: '$' }
  end

  let!(:attri_fail) do
    { name: '', symbol: 'PLZ' }
  end

  context 'User should not be able to view units' do
    before :each do
      sign_in @user
    end

    it 'GET index returns http redirect' do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

  context 'AdminUser should be able to create, destroy and update units' do
    before :each do
      sign_in @adminuser
    end

    it 'GET edit returns http success' do
      get :edit, id: @unit.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'Update unit and redirect to unit edit page' do
      put :update, id: @unit.id, unit: attri
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(units_path)
      @unit.reload
      expect(@unit.name).to eq('Dolar')
    end

    it 'GET a new unit' do
      get :new
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'AdminUser should be able to create a new unit for actor' do
      post :create, unit: attri
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(Unit.last.symbol).to eq('$')
    end

    it 'Delete unit' do
      delete :destroy, id: @unit.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(units_path)
      expect(Unit.count).to eq(0)
    end
  end

  context 'Validation on update name' do
    before :each do
      sign_in @adminuser
    end

    render_views

    it 'AdminUser should not be able to update unit without name' do
      put :update, id: @unit.id, unit: attri_fail
      expect(response.body).to match('can&#39;t be blank')
    end

    it 'AdminUser should not be able to create unit without name' do
      post :create, unit: attri_fail
      expect(response.body).to match('Please review the problems below:')
    end
  end
end
