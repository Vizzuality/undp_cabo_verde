require 'rails_helper'

RSpec.describe ActionActorRelation, type: :model do
  before :each do
    @user  = create(:user)
    @macro = create(:action_macro, user_id: @user.id)
    @meso  = create(:action_meso, user_id: @user.id)
    @micro = create(:action_micro, user_id: @user.id)
    @actor = create(:actor_macro, actions: [@macro, @meso, @micro])
  end

  it 'Create Relation action actor' do
    expect(@macro.name).to eq('First one')
    expect(@actor.name).to eq('Organization one')
    expect(Actor.count).to eq(1)
    expect(Action.count).to eq(3)
    expect(@micro.actors.count).to eq(1)
    expect(@macro.actors.count).to eq(1)
    expect(@micro.actor_mesos.count).to eq(0)
    expect(@macro.actor_micros.count).to eq(0)
    expect(ActionActorRelation.count).to eq(3)
  end

  it 'Delete Relation macro actor' do
    @macro.destroy
    expect(ActionActorRelation.count).to eq(2)
    expect(@actor.action_macros.count).to eq(0)
  end

  it 'Get actors for macro, meso and micro actions' do
    expect(@actor.actions.count).to eq(3)
    expect(@actor.action_macros.count).to eq(1)
    expect(@actor.action_mesos.count).to eq(1)
    expect(@actor.action_micros.count).to eq(1)
  end

  it 'Get relations dates' do
    @relation = ActionActorRelation.last.update_attributes(end_date: Time.zone.now, start_date: Time.zone.now - 30.years)
    expect(ActionActorRelation.get_dates(@micro, @actor)).to eq(["September  1, 1985", "September  1, 2015"])
  end

  it 'Get relations start_date' do
    @relation = ActionActorRelation.last.update_attributes(start_date: Time.zone.now - 30.years)
    expect(ActionActorRelation.get_dates(@micro, @actor)).to eq(["September  1, 1985", nil])
  end

  it 'Get relations end_date' do
    @relation = ActionActorRelation.last.update_attributes(end_date: Time.zone.now)
    expect(ActionActorRelation.get_dates(@micro, @actor)).to eq([nil, "September  1, 2015"])
  end
end
