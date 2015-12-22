require 'rails_helper'

RSpec.describe ActLocalization, type: :model do
  before :each do
    @user  = create(:user)
    @localization = create(:localization, name: 'First Localization', user: @user)
    @macro = create(:act_macro, user_id: @user.id, localizations: [@localization])
    @meso  = create(:act_meso, user_id: @user.id, localizations: [@localization])
    @micro = create(:act_micro, user_id: @user.id, localizations: [@localization])
  end

  it 'Create Relation act localization' do
    expect(@macro.name).to eq('First one')
    expect(@localization.name).to eq('First Localization')
    expect(Localization.count).to eq(1)
    expect(Act.count).to eq(3)
    expect(@micro.localizations.count).to eq(1)
    expect(@macro.localizations.count).to eq(1)
    expect(ActLocalization.count).to eq(3)
  end

  it 'Delete Relation macro localization' do
    @macro.destroy
    expect(ActLocalization.count).to eq(2)
    expect(@localization.act_macros.count).to eq(0)
  end

  it 'Get localizations for macro, meso and micro acts' do
    expect(@localization.acts.count).to eq(3)
    expect(@localization.act_macros.count).to eq(1)
    expect(@localization.act_mesos.count).to eq(1)
    expect(@localization.act_micros.count).to eq(1)
  end

  context 'For main localizations' do
    before :each do
      @localization_new = create(:localization, name: 'Main Localization', user: @user)
    end

    it 'Set other location for action meso as main location' do
      expect(@meso.localizations.count).to eq(1)
      ActMeso.find(@meso.id).update!(localizations: [@localization_new])
      expect(@meso.main_location_name).to eq('Main Localization')
    end
  end
end
