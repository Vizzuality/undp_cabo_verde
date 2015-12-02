require 'rails_helper'

RSpec.describe ActorsController, type: :controller do
  before :each do
    @user      = create(:random_user)
    @adminuser = create(:adminuser)
    FactoryGirl.create(:admin)

    @micro = create(:actor_micro, user_id: @user.id)
    @macro = create(:actor_macro, user_id: @user.id, active: false)
    @meso  = create(:actor_meso, user_id: @user.id)
  end
  
  let!(:attri) do 
    { name: 'New first', observation: 'Lorem ipsum dolor...', 
      active: true, title: '', operational_filed: '' 
    }
  end

  let!(:attri_macro_micro) do 
    { name: 'New first', observation: 'Lorem ipsum dolor...', 
      active: true, title: 'Test', operational_filed: 2 
    }
  end

  let!(:attri_meso) do 
    { name: 'New first', observation: 'Lorem ipsum dolor...', 
      active: true, title: 'Test', type: 'ActorMeso' 
    }
  end

  let!(:attri_fail) do
    { name: '' }
  end

  context 'Actors for authenticated user' do
    before :each do
      sign_in @user
    end

    it 'GET index returns http success' do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'GET show returns http success' do
      get :show, id: @macro.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(@macro.macro?).to eq(true)
    end

    render_views

    it 'GET edit returns http success' do
      get :edit, id: @micro.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(@micro.micro?).to eq(true)
    end

    it 'update actor micro and redirect to membership_actor_micro_path' do
      put :update, id: @micro.id, actor: attri_macro_micro
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@micro.micro?).to eq(true)
    end

    it 'update actor meso and redirect to membership_actor_meso_path' do
      put :update, id: @meso.id, actor: attri
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@meso.meso?).to eq(true)
    end

    it 'update actor macro and redirect to actor_path' do
      put :update, id: @macro.id, actor: attri_macro_micro
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@macro.macro?).to eq(true)
    end

    it 'Validate title for update actor micro' do
      FactoryGirl.create(:actor_macro, user_id: @user.id)
      put :update, id: @micro.id, actor: attri
      expect(response.body).to match('can&#39;t be blank')
    end

    it 'Validate name for update actor' do
      FactoryGirl.create(:actor_macro, user_id: @user.id)
      put :update, id: @meso.id, actor: attri_fail
      expect(response.body).to match('can&#39;t be blank')
    end

    it 'Validate operational_field for update actor macro' do
      put :update, id: @macro.id, actor: attri
      expect(response.body).to match('can&#39;t be blank')
    end

    it 'update actor macro with new type and redirect to actor_path' do
      put :update, id: @macro.id, actor: attri_meso
      @new_meso = Actor.find(@macro.id).reload
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@new_meso.meso?).to eq(true)
    end

    it 'delete actor' do
      delete :destroy, id: @macro.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@macro.micro_or_meso?).to eq(false)
    end

    context 'User should be able to add categories to actors' do
      before :each do
        @category  = create(:category)
        @child_cat = create(:category, name: 'Category second', parent: @category, actors: [@micro, @meso])
      end

      let!(:attri_macro_micro_with_cat) do 
        { name: 'New first', observation: 'Lorem ipsum dolor...', 
          active: true, title: 'Test', operational_filed: 2, category_ids: [@child_cat]
        }
      end

      it 'Add categories to actor' do
        put :update, id: @macro.id, actor: attri_macro_micro_with_cat
        expect(response).to be_redirect
        expect(response).to have_http_status(302)
        expect(@macro.categories.count).to eq(1)
      end
    end

    
    context 'Link unlink macros and mesos' do
      before :each do
        @macro_active = create(:actor_macro, user_id: @user.id)
        @meso_linked  = create(:actor_meso,  user_id: @user.id, 
                               parents: [@macro_active])
        @micro_linked = create(:actor_micro, user_id: @user.id, 
                               parents: [@macro_active, @meso_linked])
        FactoryGirl.create(:actor_macro, user_id: @user.id)
        FactoryGirl.create(:actor_meso, user_id: @user.id)
      end

      it 'Get actors to link' do
        get :membership, id: @micro_linked.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
        expect(Actor.filter_actives.not_macros_parents(@micro).count).to eq(2)
        expect(Actor.filter_actives.not_mesos_parents(@micro).count).to eq(3)
      end

      it 'Link macro as micro' do
        patch :link_actor, id: @micro.id, parent_id: @macro_active.id, type: 'ActorMicro'
      end

      it 'Unlink macro as micro' do
        patch :unlink_actor, id: @micro_linked.id, parent_id: @macro_active.id, type: 'ActorMicro'
      end

      it 'Link macro as meso' do
        patch :link_actor, id: @meso.id, parent_id: @macro_active.id, type: 'ActorMeso'
      end

      it 'Unlink macro as meso' do
        patch :unlink_actor, id: @meso_linked.id, parent_id: @macro_active.id, type: 'ActorMeso'
      end

      it 'Link meso' do
        patch :link_actor, id: @micro.id, parent_id: @meso.id, type: 'ActorMicro'
      end

      it 'Unlink meso' do
        patch :unlink_actor, id: @micro_linked.id, parent_id: @meso_linked.id, type: 'ActorMicro'
      end
    end

  end

  context 'Users' do
    it 'GET index returns http success' do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'GET show returns http success' do
      get :show, id: @micro.id, type: 'ActorMicro'
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

  context 'AdminUser should be able to activate or deactivate actor' do
    before :each do
      sign_in @adminuser
    end

    it 'Activate actor' do
      patch :activate, id: @macro.id, type: 'ActorMacro'
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end

    it 'Deactivate actor' do
      patch :deactivate, id: @micro.id, type: 'ActorMicro'
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end
  end

  context 'User should not be able to edit actors if self status is deactivated' do
    before :each do
      @user.update(active: false)
      sign_in @user
    end

    render_views

    it 'Edit actor' do
      expect(@user.deactivated?).to eq(true)
      get :edit, id: @macro.id, type: 'ActorMacro'
      expect(response).to redirect_to('/')
      expect(flash[:alert]).to eq('You are not authorized to access this page.')
    end
  end

  context 'AdminUser should be able to filter for active and inactive actors' do
    render_views

    before :each do
      sign_in @adminuser
    end

    it 'Filter for active actors' do
      get :index, { active: 'true' }
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).to match('Person one')
      expect(response.body).not_to match('Organization one')
    end

    it 'Filter for inactive actors' do
      get :index, { active: 'false' }
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).not_to match('Person one')
      expect(response.body).to match('Organization one')
    end

    it 'GET a new actor' do
      get :new, type: 'ActorMacro'
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'User should be able to create a new actor' do
      post :create, actor: { name: 'New first', user_id: @adminuser.id, type: 'ActorMacro' }
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@adminuser.actors.count).to eq(1)
    end

    it 'User should not be able to create a new actor without name' do
      post :create, actor: { name: '', user_id: @adminuser.id, type: 'ActorMacro' }
      expect(response.body).to match('can&#39;t be blank')
    end
  end
end
