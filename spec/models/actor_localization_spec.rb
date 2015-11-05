require 'rails_helper'

RSpec.describe ActorLocalization, type: :model do
  
  before :each do
    @user  = create(:user)
    @macro = create(:actor_macro, user_id: @user.id)
    @meso  = create(:actor_meso, user_id: @user.id)
    @micro = create(:actor_micro, user_id: @user.id)
    @localization = create(:localization, name: 'First Localization', actors: [@macro, @meso, @micro])
  end

  it 'Create Relation actor localization' do
    expect(@macro.name).to eq('Organization one')
    expect(@localization.name).to eq('First Localization')
    expect(Localization.count).to eq(1)
    expect(Actor.count).to eq(3)
    expect(@micro.localizations.count).to eq(1)
    expect(@macro.localizations.count).to eq(1)
    expect(ActorLocalization.count).to eq(3)
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

end
