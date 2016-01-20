require 'rails_helper'

RSpec.describe User, type: :model do
  before :each do
    @user = create(:user)
  end

  it 'Users count' do
    expect(User.count).to eq(1)
  end

  it 'Deactivate activate user' do
    @user.deactivate
    expect(User.count).to eq(1)
    expect(User.filter_inactives.count).to eq(1)
    expect(@user.deactivated?).to be(true)
    @user.activate
    expect(@user.activated?).to be(true)
    expect(User.filter_actives.count).to be(1)
  end
end