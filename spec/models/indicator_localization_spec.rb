require 'rails_helper'

RSpec.describe IndicatorLocalization, type: :model do
  before :each do
    @user         = create(:user)
    @indicator_1  = create(:indicator, user_id: @user.id)
    @indicator_2  = create(:indicator, name: 'Indicator two', user_id: @user.id)
    @location_1   = create(:localization, user_id: @user.id, name: 'First Localization', indicators: [@indicator_1])
    @location_2   = create(:localization, user_id: @user.id, name: 'Second Localization', indicators: [@indicator_2])
  end

  it 'Create Relation indicator localization' do
    expect(@location_1.name).to eq('First Localization')
    expect(Localization.count).to eq(2)
    expect(@indicator_1.localizations.count).to eq(1)
    expect(@location_1.indicators.count).to eq(1)
    expect(IndicatorLocalization.count).to eq(2)
  end

  it 'Delete Relation indicator localization' do
    @indicator_1.destroy
    expect(IndicatorLocalization.count).to eq(1)
    expect(@location_1.indicators.count).to eq(0)
  end

  it 'Deactivate activate location if indicator deactivated' do
    @indicator_2.deactivate
    expect(@indicator_2.localizations.first.name).to eq('Second Localization')
    expect(Indicator.filter_inactives.count).to eq(1)
    expect(@indicator_2.deactivated?).to be(true)
    @location_2.reload
    expect(@location_2.deactivated?).to be(true)
    expect(Localization.filter_inactives.count).to be(1)
    expect(Localization.filter_actives.count).to be(1)
  end

  context 'For main localizations' do
    before :each do
      @localization_new = create(:localization, name: 'Main Localization', user: @user)
    end

    it 'Set other location for indicator as main location' do
      expect(@indicator_1.localizations.count).to eq(1)
      Indicator.find(@indicator_1.id).update!(localizations: [@localization_new])
      expect(@indicator_1.main_location_name).to eq('Main Localization')
    end
  end
end
