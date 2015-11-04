require 'rails_helper'

RSpec.describe Users::ActorsController, type: :controller do

  before :each do
    @user  = create(:user)
    @micro = create(:actor_micro, user_id: @user.id)
    @macro = create(:actor_macro, user_id: @user.id)
    @meso  = create(:actor_meso,  user_id: @user.id)

    sign_in @user
  end

  context 'Actors for authenticated user' do
    render_views

    it 'GET actors index for specific user returns http success' do
      get :index, user_id: @user.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).to match('Person one')
      expect(response.body).to match('Department one')
      expect(response.body).to match('Organization one')
    end
  end
end
