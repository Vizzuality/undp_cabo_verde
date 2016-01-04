require 'rails_helper'

RSpec.describe ActorLocalization, type: :model do
  before :each do
    @user  = create(:user)
    @localization = create(:localization, name: 'First Localization', user: @user)
    @macro = create(:actor_macro, user_id: @user.id, localizations: [@localization])
    @meso  = create(:actor_meso, user_id: @user.id, localizations: [@localization])
    @micro = create(:actor_micro, user_id: @user.id, localizations: [@localization])
  end

  it 'Create Relation actor localization' do
    expect(@macro.name).to eq('Organization one')
    expect(@localization.name).to eq('First Localization')
    expect(Localization.count).to eq(1)
    expect(Actor.count).to eq(3)
    expect(@micro.localizations.count).to eq(1)
    expect(@macro.localizations.count).to eq(1)
    expect(ActorLocalization.count).to eq(3)
    expect(@macro.main_location_name).to eq('First Localization')
  end

  it 'Delete Relation macro localization' do
    @macro.destroy
    expect(ActorLocalization.count).to eq(2)
    expect(@localization.actor_macros.count).to eq(0)
  end

  it 'Get localizations for macro, meso and micro actors' do
    expect(@localization.actors.count).to eq(3)
    expect(@localization.actor_macros.count).to eq(1)
    expect(@localization.actor_mesos.count).to eq(1)
    expect(@localization.actor_micros.count).to eq(1)
  end
  
  context 'For main localizations' do
    before :each do
      @localization_new = create(:localization, name: 'Main Localization', user: @user)
    end

    it 'Set other location for actor meso as main location' do
      expect(@meso.localizations.count).to eq(1)
      ActorMeso.find(@meso.id).update!(localizations: [@localization_new])
      expect(@meso.main_location_name).to eq('Main Localization')
    end
  end
end
