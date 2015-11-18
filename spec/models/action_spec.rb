require 'rails_helper'

RSpec.describe Action, type: :model do
  before :each do
    @user  = create(:user)
    @macro = create(:action_macro, user_id: @user.id)
    @meso  = create(:action_meso, user_id: @user.id, parents: [@macro])
    @micro = create(:action_micro, user_id: @user.id, parents: [@macro, @meso], end_date: Time.zone.now, start_date: Time.zone.now - 30.years)
    @relation = ActionRelation.find_by(parent_id: @meso.id, child_id: @micro.id)
  end

  it 'Create ActionMacro' do
    expect(@macro.name).to eq('First one')
    expect(@macro.mesos.first.name).to eq('Second one')
    expect(@macro.micros.first.name).to eq('Third one')
    expect(@macro.macro?).to eq(true)
  end

  it 'Create ActionMeso' do
    expect(@meso.name).to eq('Second one')
    expect(@meso.micros.first.name).to eq('Third one')
    expect(@meso.macros_parents.first.name).to eq('First one')
    expect(@meso.meso?).to eq(true)
  end

  it 'Create ActionMicro' do
    expect(@micro.name).to eq('Third one')
    expect(@micro.macros_parents.first.name).to eq('First one')
    expect(@micro.mesos_parents.first.name).to eq('Second one')
    expect(@micro.micro?).to eq(true)
    expect(@micro.startdate).to eq((Time.zone.now - 30.years).to_date)
    expect(@micro.enddate).to eq(Time.zone.now.to_date)
  end

  it 'order action by name' do
    expect(Action.order(name: :asc)).to eq([@macro, @meso, @micro])
    expect(Action.count).to eq(3)
    expect(ActionMicro.count).to eq(1)
    expect(ActionMeso.count).to eq(1)
    expect(ActionMacro.count).to eq(1)
  end

  it 'action name validation' do
    @action_reject = ActionMicro.new(name: '', user_id: @user.id)

    @action_reject.valid?
    expect {@action_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it 'action with action type' do
    expect(@micro.type).to eq('ActionMicro')
  end

  it 'action with user' do
    expect(@micro.user.name).to eq('Pepe Moreno')
    expect(@user.actions.count).to eq(3)
    expect(@user.action_micros.count).to eq(1)
    expect(@user.action_macros.count).to eq(1)
    expect(@user.action_mesos.count).to eq(1)
    expect(@micro.micro_or_meso?).to eq(true)
  end

  it 'Deactivate activate action' do
    @micro.deactivate
    expect(ActionMicro.count).to eq(1)
    expect(ActionMicro.filter_inactives.count).to eq(1)
    expect(@micro.deactivated?).to be(true)
    @micro.activate
    expect(@micro.activated?).to be(true)
    expect(ActionMicro.filter_actives.count).to be(1)
  end
end
