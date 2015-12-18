require 'rails_helper'

RSpec.describe Users::IndicatorsController, type: :controller do
  before :each do
    @user  = create(:user)
    @indicator_1 = create(:indicator, user_id: @user.id)
    @indicator_2 = create(:indicator, name: 'Indicator two', user_id: @user.id)

    sign_in @user
  end

  context 'Indicators for authenticated user' do
    render_views

    it 'GET indicators index for specific user returns http success' do
      get :index, user_id: @user.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.body).to match('Indicator one')
      expect(response.body).to match('Indicator two')
    end
  end
end
