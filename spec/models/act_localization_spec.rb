require 'rails_helper'

RSpec.describe ActLocalization, type: :model do
  before :each do
    @user  = create(:user)
    @macro = create(:act_macro, user_id: @user.id)
    @meso  = create(:act_meso, user_id: @user.id)
    @micro = create(:act_micro, user_id: @user.id)
    @localization = create(:localization, name: 'First Localization', acts: [@macro, @meso, @micro])
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
end
