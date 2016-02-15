require 'rails_helper'

RSpec.describe Favourite, type: :model do
  context 'Favourites for search' do
    before :each do
      @user       = create(:user)
      @favourite  = create(:favourite, user_id: @user.id)
    end

    it 'Create Favourite' do
      expect(@favourite.name).not_to       be_nil
      expect(@favourite.favorable_type).to eq('Search')
      expect(@favourite.favorable_id).to   eq(@favourite.id)
      expect(@favourite.uri).not_to        be_nil
    end

    it 'Favourite uri validation' do
      @favourite_reject = Favourite.new(uri: '', user: @user)

      @favourite_reject.valid?
      expect {@favourite_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Uri can't be blank")
    end
  end
end
