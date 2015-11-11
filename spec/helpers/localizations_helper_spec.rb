require 'rails_helper'

describe LocalizationsHelper, type: :helper do
  include ApplicationHelper

  before :each do
    @user  = create(:random_user)
    @micro = create(:actor_micro, user_id: @user.id)
    @localization   = create(:localization, name: 'First Localization', 
                             actors: [@micro], user_id: @user.id)
  end

  context 'localizations for actors' do
    it 'edit path' do
      expect(helper.polymorphic_localization_path(@micro, @localization)).to eq(actor_localization_path(actor_id: @micro, id: @localization))
    end

    it 'create path' do
      expect(helper.polymorphic_create_localization_path(@micro)).to eq(actor_localizations_path(actor_id: @micro))
    end
  end
end
