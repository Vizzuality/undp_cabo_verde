require 'rails_helper'

RSpec.describe ActsController, type: :controller do
  before :each do
    @user      = create(:random_user)
    @adminuser = create(:adminuser)
    FactoryGirl.create(:admin)

    @micro = create(:act_micro, user_id: @user.id)
    @macro = create(:act_macro, user_id: @user.id, active: false)
    @meso  = create(:act_meso, user_id: @user.id)
    @socio_cultural_domain = create(:socio_cultural_domain)
  end

  let!(:attri) do
    { name: 'New first', active: true }
  end

  let!(:attri_macro_micro) do
    { name: 'New first', active: true }
  end

  let!(:attri_fail) do
    { name: '' }
  end

  context 'Acts for authenticated user' do
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

    it 'update act micro and redirect to membership_act_micro_path' do
      put :update, id: @micro.id, act: attri_macro_micro
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@micro.micro?).to eq(true)
    end

    it 'update act meso and redirect to membership_act_meso_path' do
      put :update, id: @meso.id, act: attri
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@meso.meso?).to eq(true)
    end

    it 'update act macro and redirect to act_path' do
      put :update, id: @macro.id, act: attri_macro_micro
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@macro.macro?).to eq(true)
    end

    it 'Validate name for update act' do
      FactoryGirl.create(:act_macro, user_id: @user.id)
      put :update, id: @meso.id, act: attri_fail
      expect(response.body).to match('can&#39;t be blank')
    end

    it 'delete act' do
      delete :destroy, id: @macro.id
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@macro.micro_or_meso?).to eq(false)
    end

    context 'User should be able to add categories to acts' do
      before :each do
        @category  = create(:category)
        @child_cat = create(:socio_cultural_domain, name: 'Category second',
                            parent: @category, acts: [@micro, @meso])
      end

      let!(:attri_macro_micro_with_cat) do 
        {
          name: 'New first',
          active: true,
          category_ids: [@child_cat]
        }
      end

      it 'Add categories to act' do
        put :update, id: @macro.id, act: attri_macro_micro_with_cat
        expect(response).to be_redirect
        expect(response).to have_http_status(302)
        expect(@macro.categories.count).to eq(1)
      end
    end

    
    context 'Link unlink macros and mesos' do
      before :each do
        @macro_active = create(:act_macro, user_id: @user.id)
        @meso_linked  = create(:act_meso,  user_id: @user.id, 
                               parents: [@macro_active])
        @micro_linked = create(:act_micro, user_id: @user.id, 
                               parents: [@macro_active, @meso_linked])
        FactoryGirl.create(:act_macro, user_id: @user.id)
        FactoryGirl.create(:act_meso, user_id: @user.id)
      end

      it 'Get acts to link' do
        get :membership, id: @micro_linked.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
        expect(Act.filter_actives.not_macros_parents(@micro).count).to eq(2)
        expect(Act.filter_actives.not_mesos_parents(@micro).count).to eq(3)
      end

      it 'Link macro as micro' do
        patch :link_act, id: @micro.id, parent_id: @macro_active.id, type: 'ActMicro'
      end

      it 'Unlink macro as micro' do
        patch :unlink_act, id: @micro_linked.id, parent_id: @macro_active.id, type: 'ActMicro'
      end

      it 'Link macro as meso' do
        patch :link_act, id: @meso.id, parent_id: @macro_active.id, type: 'ActMeso'
      end

      it 'Unlink macro as meso' do
        patch :unlink_act, id: @meso_linked.id, parent_id: @macro_active.id, type: 'ActMeso'
      end

      it 'Link meso' do
        patch :link_act, id: @micro.id, parent_id: @meso.id, type: 'ActMicro'
      end

      it 'Unlink meso' do
        patch :unlink_act, id: @micro_linked.id, parent_id: @meso_linked.id, type: 'ActMicro'
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
      get :show, id: @micro.id, type: 'ActMicro'
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

  context 'AdminUser should be able to activate or deactivate act' do
    before :each do
      sign_in @adminuser
    end

    it 'Activate act' do
      patch :activate, id: @macro.id, type: 'ActMacro'
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end

    it 'Deactivate act' do
      patch :deactivate, id: @micro.id, type: 'ActMicro'
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end
  end

  context 'User should not be able to edit acts if self status is deactivated' do
    before :each do
      @user.update(active: false)
      sign_in @user
    end

    render_views

    it 'Edit act' do
      expect(@user.deactivated?).to eq(true)
      get :edit, id: @macro.id, type: 'ActMacro'
      expect(response).to redirect_to('/')
      expect(flash[:alert]).to eq('You are not authorized to access this page.')
    end
  end

  context 'AdminUser should be able to filter for active and inactive acts' do
    render_views

    before :each do
      sign_in @adminuser
    end

    it 'Filter for active acts' do
      get :index, { active: 'true' }
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).to match('Third one')
      expect(response.body).not_to match('First one')
    end

    it 'Filter for inactive acts' do
      get :index, { active: 'false' }
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).not_to match('Third one')
      expect(response.body).to match('First one')
    end

    it 'GET a new act' do
      get :new, type: 'ActMacro'
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'User should be able to create a new act' do
      post :create, act: { name: 'New first', user_id: @adminuser.id, type: 'ActMacro' }
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
      expect(@adminuser.acts.count).to eq(1)
    end

    it 'User should not be able to create a new act without name' do
      post :create, act: { name: '', user_id: @adminuser.id, type: 'ActMacro' }
      expect(response.body).to match('can&#39;t be blank')
    end
  end
end
