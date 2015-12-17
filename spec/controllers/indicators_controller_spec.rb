require 'rails_helper'

RSpec.describe IndicatorsController, type: :controller do
  before :each do
    @user      = create(:random_user)
    @adminuser = create(:adminuser)
    FactoryGirl.create(:admin)

    @indicator_1 = create(:indicator, user_id: @user.id)
    @indicator_2 = create(:indicator, name: 'Indicator two', user_id: @user.id, active: false)
    @act         = create(:act_meso, user_id: @user.id, indicators: [@indicator_1, @indicator_2])
  end

  let!(:attri) do 
    { name: 'New first', description: 'Lorem ipsum dolor...', user_id: @user.id }
  end

  let!(:attri_fail) do
    { name: '', user_id: @user.id }
  end

  context 'Indicators for authenticated user' do
    before :each do
      sign_in @user
    end

    it 'GET index returns http success' do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'GET show returns http success' do
      get :show, id: @indicator_1.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'GET edit returns http success' do
      get :edit, id: @indicator_2.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'update indicator micro and redirect to membership_indicator_micro_path' do
      put :update, id: @indicator_2.id, indicator: attri
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      @indicator_2.reload
      expect(@indicator_2.name).to eq('New first')
    end
    
    render_views
    it 'Validate name for update indicator' do
      put :update, id: @indicator_2.id, indicator: attri_fail
      expect(response.body).to match('can&#39;t be blank')
    end

    it 'delete indicator' do
      delete :destroy, id: @indicator_1.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(Indicator.count).to eq(1)
    end

    context 'User should be able to add categories to indicators' do
      before :each do
        @category = create(:category)
      end

      let!(:attri_indicator_with_cat) do
        { name: 'New first', description: 'Lorem ipsum dolor...',
          active: true, alternative_name: 'Test', category_ids: [@category]
        }
      end

      it 'Add categories to indicator' do
        put :update, id: @indicator_1.id, indicator: attri_indicator_with_cat
        expect(response).to be_redirect
        expect(response).to have_http_status(302)
        expect(@indicator_1.categories.count).to eq(1)
      end
    end
  end

  context 'Users' do
    it 'GET index returns access denied without login' do
      get :index
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(flash[:alert]).to eq('You need to sign in or sign up before continuing.')
    end

    it 'GET show returns access denied de without login' do
      get :show, id: @indicator_2.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(flash[:alert]).to eq('You need to sign in or sign up before continuing.')
    end
  end

  context 'AdminUser should be able to activate or deactivate indicator' do
    before :each do
      sign_in @adminuser
    end

    it 'Activate indicator' do
      patch :activate, id: @indicator_2.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      @indicator_2.reload
      expect(@indicator_2.activated?).to eq(true)
    end

    it 'Deactivate indicator' do
      patch :deactivate, id: @indicator_1.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      @indicator_1.reload
      expect(@indicator_1.deactivated?).to eq(true)
    end
  end

  context 'User should not be able to edit indicators if self status is deactivated' do
    before :each do
      @user.update(active: false)
      sign_in @user
    end

    render_views

    it 'Edit indicator' do
      expect(@user.deactivated?).to eq(true)
      get :edit, id: @indicator_1.id
      expect(response).to redirect_to('/')
      expect(flash[:alert]).to eq('You are not authorized to access this page.')
    end
  end

  context 'AdminUser should be able to filter for active and inactive indicators' do
    render_views

    before :each do
      sign_in @adminuser
    end

    it 'Filter for active indicators' do
      get :index, { active: 'true' }
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).to match('Indicator one')
      expect(response.body).not_to match('Indicatoe two')
    end

    it 'Filter for inactive indicators' do
      get :index, { active: 'false' }
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).not_to match('Indicator one')
      expect(response.body).to match('Indicator two')
    end

    it 'GET a new indicator' do
      get :new
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'User should be able to create a new indicator' do
      post :create, indicator: attri
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@adminuser.indicators.count).to eq(1)
    end

    it 'User should not be able to create a new indicator without name' do
      post :create, indicator: attri_fail
      expect(response.body).to match('can&#39;t be blank')
    end
  end
end
