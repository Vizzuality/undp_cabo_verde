require 'rails_helper'

RSpec.describe Users::ActsController, type: :controller do
  before :each do
    @user  = create(:user)
    @micro = create(:act_micro, user_id: @user.id)
    @macro = create(:act_macro, user_id: @user.id)
    @meso  = create(:act_meso,  user_id: @user.id)

    sign_in @user
  end

  context 'Actors for authenticated user' do
    render_views

    it 'GET acts index for specific user returns http success' do
      get :index, user_id: @user.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).to match('Third one')
      expect(response.body).to match('Second one')
      expect(response.body).to match('First one')
    end
  end
end
