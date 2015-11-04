require 'rails_helper'

RSpec.describe ActorMicroMesosController, type: :controller do

  before :each do
    @user = create(:random_user)
    @adminuser = create(:adminuser)
    FactoryGirl.create(:admin)

    @meso  = create(:actor_meso, user_id: @user.id)
    @micro = create(:actor_micro, user_id: @user.id, mesos: [@meso])
    @micro_meso = ActorMicroMeso.find_by(micro_id: @micro.id, meso_id: @meso.id)
  end
  
  let!(:attri_meso) do 
    { meso_end_date: Time.now, meso_start_date: Time.now - 10.days }
  end

  context 'User can update start and end date for relation' do
    before :each do
      sign_in @user
    end

    render_views

    it 'GET edit returns http success' do
      get :edit, actor_micro_id: @micro.id, relation_id: @micro_meso.id, type: 'ActorMicro'
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).to match('Membership details')
    end

    it 'update actor' do
      put :update, relation_id: @micro_meso.id, actor_micro_meso: attri_meso
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
      get :edit, actor_micro_id: @micro.id, relation_id: @micro_meso.id, type: 'ActorMicro'
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).to match('Membership details')
    end

    it 'update actor' do
      put :update, relation_id: @micro_meso.id, actor_micro_meso: attri_meso
      expect(response).to be_redirect
      expect(response).to have_http_status(302)
    end
  end

end
