require 'rails_helper'

RSpec.describe User, type: :model do
  
  before :each do
    @user = create(:user)
  end
  
  it "Users count" do
    expect(User.count).to eq(1)
  end

end