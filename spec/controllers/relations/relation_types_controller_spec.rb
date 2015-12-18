require 'rails_helper'

RSpec.describe RelationTypesController, type: :controller do
  before :each do
    @user      = create(:random_user)
    @adminuser = create(:adminuser)
    FactoryGirl.create(:admin)

    @actors_relation_type = create(:actors_relation_type)
    @acts_relation_type   = create(:acts_relation_type)
  end
  
  let!(:attri) do 
    { title: 'contains', title_reverse: 'belong to', relation_category: 5 }
  end

  let!(:attri_fail) do 
    { title: '' }
  end

  let!(:attri_fail_reverse) do 
    { title_reverse: '' }
  end

  context 'User should not be able to access relation types' do
    before :each do
      sign_in @user
    end

    it 'GET index returns access denied' do
      get :index
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(flash[:alert]).to eq('You are not authorized to access this page.')
    end

    it 'GET show returns access denied' do
      get :edit, id: @actors_relation_type.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(flash[:alert]).to eq('You are not authorized to access this page.')
    end

    it 'GET show returns access denied' do
      get :new
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(flash[:alert]).to eq('You are not authorized to access this page.')
    end
  end

  context 'AdminUser should be able to manage relation types' do
    before :each do
      sign_in @adminuser
    end

    it 'GET index returns http success' do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'GET edit returns http success' do
      get :edit, id: @actors_relation_type.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'Update relation_type and redirect to relation_types index page' do
      put :update, id: @acts_relation_type.id, relation_type: attri
      @acts_relation_type.reload
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(relation_types_path)
      expect(@acts_relation_type.title).to eq('contains')
      expect(@acts_relation_type.relation_category).to eq(5)
    end

    it 'GET a new relation_type' do
      get :new
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'AdminUser should be able to create a new relation_type for actor' do
      post :create, relation_type: attri
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(RelationType.last.relation_category).to eq(5)
    end

    it 'Delete relation_type' do
      delete :destroy, id: @actors_relation_type.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(relation_types_path)
      expect(RelationType.count).to eq(1)
    end
  end

  context 'Validation on update title' do
    before :each do
      sign_in @adminuser
    end

    render_views
    
    it 'AdminUser should not be able to update relation_type without title' do
      put :update, id: @actors_relation_type.id, relation_type: attri_fail
      expect(response.body).to match('can&#39;t be blank')
    end

    it 'AdminUser should not be able to create relation_type without title_reverse' do
      post :create, relation_type: attri_fail_reverse
      expect(response.body).to match('can&#39;t be blank')
    end
  end
end
