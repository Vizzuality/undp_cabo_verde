require 'rails_helper'

RSpec.describe LocalizationsController, type: :controller do

  before :each do
    @user      = create(:random_user)
    @adminuser = create(:adminuser)
    FactoryGirl.create(:admin)

    @micro = create(:actor_micro, user_id: @user.id)
    @macro = create(:actor_macro, user_id: @user.id)
    @meso  = create(:actor_meso,  user_id: @user.id)
    @localization   = create(:localization, name: 'First Localization', 
                             actors: [@micro, @macro, @meso], user_id: @user.id)
    @localization_2 = create(:localization, name: 'First Localization', 
                             actors: [@meso], user_id: @user.id, active: false)
  end
  
  let!(:attri) do 
    { name: 'New addr', lat: Faker::Address.latitude, 
      long: Faker::Address.longitude, country: Faker::Address.country 
    }
  end

  let!(:attri_fail) do 
    { name: 'New addr', lat: Faker::Address.latitude, 
      long: '', country: Faker::Address.country 
    }
  end

  context 'Localizations for actors' do

    before :each do
      sign_in @user
    end

    it 'GET edit returns http success' do
      get :edit, id: @localization.id, actor_id: @meso.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'Update localization and redirect to actor edit page' do
      put :update, id: @localization.id, actor_id: @macro.id, localization: attri
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(edit_actor_path(@macro))
      expect(@macro.localizations.first.name).to eq('New addr')
    end

    it 'GET a new localization' do
      get :new, actor_id: @macro.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'User should be able to create a new localization for actor' do
      post :create, actor_id: @micro.id, localization: attri
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(edit_actor_path(@micro))
      expect(@micro.localizations.size).to eq(2)
      expect(@micro.localizations.first.name).to eq('First Localization')
      expect(@micro.localizations.last.name).to eq('New addr')
    end

    it 'Delete localization' do
      delete :destroy, id: @localization.id, actor_id: @micro.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(edit_actor_path(@micro))
      expect(@micro.localizations.size).to eq(0)
    end

    context 'AdminUser should be able to activate, deactivate and update localizations' do
      before :each do
        sign_in @adminuser
        expect(@meso.localizations.size).to eq(2)
      end

      it 'Activate localization' do
        patch :activate, id: @localization_2.id, actor_id: @meso.id
        expect(response).to be_redirect
        expect(response).to have_http_status(302)
        expect(@meso.localizations.filter_actives.size).to eq(2)
      end

      it 'Deactivate localization' do
        patch :deactivate, id: @localization.id, actor_id: @meso.id
        expect(response).to be_redirect
        expect(response).to have_http_status(302)
        expect(@meso.localizations.filter_actives.size).to eq(0)
        expect(@meso.localizations.filter_inactives.size).to eq(2)
      end

      it 'Update localization and redirect to actor edit page' do
        put :update, id: @localization.id, actor_id: @macro.id, localization: attri
        expect(response).to be_redirect
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(edit_actor_path(@macro))
        expect(@macro.localizations.first.name).to eq('New addr')
      end
    end

    context 'Validation' do
      render_views
      
      it 'User should not be able to update localization without longtitude' do
        put :update, id: @localization.id, actor_id: @macro.id, localization: attri_fail
        expect(response.body).to match('can&#39;t be blank')
      end
    end
  end
end