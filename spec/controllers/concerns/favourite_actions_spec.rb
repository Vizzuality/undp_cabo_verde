require 'rails_helper'

RSpec.describe ActorsController, type: :controller do
  before :each do
    @user      = create(:random_user)
    @macro = create(:actor_macro, user_id: @user.id, active: false)
    @meso  = create(:actor_meso, user_id: @user.id)
    FactoryGirl.create(:favourite, favorable_id: @macro.id, favorable_type: 'ActorMacro', uri: "/actors/#{@macro.id}", user: @user)
  end

  context 'Favourites for actor' do
    before :each do
      sign_in @user
    end

    render_views

    it 'User should be able to delete favourite on actor' do
      expect(@user.favourites.count).to eq(1)
      delete :destroy_favourite, id: @macro.id, format: 'js'
      expect(response).to have_http_status(200)
      expect(@user.favourites.count).to eq(0)
    end

    it 'User should be able to create favourite on actor' do
      post :create_favourite, id: @meso.id, format: 'js'
      expect(response).to have_http_status(200)
      expect(@user.favourites.count).to eq(2)
    end
  end
end
