require 'rails_helper'

RSpec.describe ActorMesoMacrosController, type: :controller do

  before :each do
    @user = create(:random_user)
    @adminuser = create(:adminuser)
    FactoryGirl.create(:admin)

    @macro = create(:actor_macro, user_id: @user.id)
    @meso  = create(:actor_meso, user_id: @user.id, macros: [@macro])
    @meso_macro = ActorMesoMacro.find_by(macro_id: @macro.id, meso_id: @meso.id)
  end
  
  let!(:attri_macro) do 
    { macro_end_date: Time.now, macro_start_date: Time.now - 10.days }
  end

  context 'User can update start and end date for relation' do
    before :each do
      sign_in @user
    end

    render_views

    it 'GET edit returns http success' do
      get :edit, actor_meso_id: @meso.id, relation_id: @meso_macro.id, type: 'ActorMeso'
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).to match('Membership details')
    end

    it 'update actor' do
      put :update, relation_id: @meso_macro.id, actor_meso_macro: attri_macro
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end
  end

  context 'Admin user can update start and end date for users relation' do
    before :each do
      sign_in @adminuser
    end

    render_views

    it 'GET edit returns http success' do
      get :edit, actor_meso_id: @meso.id, relation_id: @meso_macro.id, type: 'ActorMeso'
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).to match('Membership details')
    end

    it 'update actor' do
      put :update, relation_id: @meso_macro.id, actor_meso_macro: attri_macro
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end
  end

end
