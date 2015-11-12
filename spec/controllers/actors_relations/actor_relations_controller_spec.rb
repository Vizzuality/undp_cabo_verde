require 'rails_helper'

RSpec.describe ActorRelationsController, type: :controller do
  before :each do
    @user = create(:random_user)
    @adminuser = create(:adminuser)
    FactoryGirl.create(:admin)

    @macro = create(:actor_macro, user_id: @user.id)
    @meso  = create(:actor_meso, user_id: @user.id, parents: [@macro])
    @micro = create(:actor_micro, user_id: @user.id, parents: [@macro, @meso])

    @meso_macro  = ActorRelation.find_by(parent_id: @macro.id, child_id: @meso.id)
    @micro_macro = ActorRelation.find_by(parent_id: @macro.id, child_id: @micro.id)
    @micro_meso  = ActorRelation.find_by(parent_id: @meso.id, child_id: @micro.id)
  end
  
  let!(:attri_macro) do 
    { end_date: Time.zone.now, start_date: Time.zone.now - 10.days }
  end

  let!(:attri_macro_fail) do 
    { end_date: Time.zone.now, start_date: '' }
  end

  context 'User can update start and end date for relation' do
    before :each do
      sign_in @user
    end

    render_views

    it 'GET edit returns http success' do
      get :edit, actor_id: @meso.id, parent_id: @macro.id, type: 'ActorMeso'
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).to match('Membership details')
    end

    it 'update actor relation' do
      put :update, relation_id: @meso_macro.id, actor_relation: attri_macro
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
      get :edit, actor_id: @meso.id, parent_id: @macro.id, type: 'ActorMeso'
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).to match('Membership details')
    end

    it 'update actor relation' do
      put :update, relation_id: @meso_macro.id, actor_relation: attri_macro
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end
  end
end
