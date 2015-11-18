require 'rails_helper'

RSpec.describe ActionLocalization, type: :model do
  before :each do
    @user  = create(:user)
    @macro = create(:action_macro, user_id: @user.id)
    @meso  = create(:action_meso, user_id: @user.id)
    @micro = create(:action_micro, user_id: @user.id)
    @localization = create(:localization, name: 'First Localization', actions: [@macro, @meso, @micro])
  end

  it 'Create Relation action localization' do
    expect(@macro.name).to eq('First one')
    expect(@localization.name).to eq('First Localization')
    expect(Localization.count).to eq(1)
    expect(Action.count).to eq(3)
    expect(@micro.localizations.count).to eq(1)
    expect(@macro.localizations.count).to eq(1)
    expect(ActionLocalization.count).to eq(3)
  end

  it 'Delete Relation macro localization' do
    @macro.destroy
    expect(ActionLocalization.count).to eq(2)
    expect(@localization.action_macros.count).to eq(0)
  end

  it 'Get localizations for macro, meso and micro actions' do
    expect(@localization.actions.count).to eq(3)
    expect(@localization.action_macros.count).to eq(1)
    expect(@localization.action_mesos.count).to eq(1)
    expect(@localization.action_micros.count).to eq(1)
  end
end
