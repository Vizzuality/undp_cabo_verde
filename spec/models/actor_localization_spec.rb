require 'rails_helper'

RSpec.describe Localization, type: :model do
  before :each do
    @user  = create(:user)
    @localization = create(:localization, name: 'First Localization', user: @user)
    @macro = create(:actor_macro, user_id: @user.id, localizations: [@localization])
  end

  it 'Create Relation actor localization' do
    expect(@macro.name).to eq('Organization one')
    expect(@localization.name).to eq('First Localization')
    expect(Localization.count).to eq(1)
    expect(@macro.localizations.count).to eq(1)
    expect(@macro.main_location_name).to eq('First Localization')
    expect(@localization.localizable_type).to eq('Actor')
  end

  it 'Delete Relation macro localization' do
    @macro.destroy
    expect(Localization.count).to eq(0)
  end

  context 'For main localizations' do
    before :each do
      expect(@macro.localizations.count).to eq(1)
      @localization_new = create(:localization, name: 'Main Localization', user: @user)
    end

    it 'Set other location for actor macro as main location' do
      @macro.update!(localizations: [@localization, @localization_new])
      expect(@macro.localizations.count).to eq(2)
      @localization_new.update!(main: true)
      expect(@macro.main_location_name).to eq('Main Localization')
    end
  end
end
