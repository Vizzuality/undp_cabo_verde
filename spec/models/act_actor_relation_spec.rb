require 'rails_helper'

RSpec.describe ActActorRelation, type: :model do
  before :each do
    @user  = create(:user)
    @macro = create(:act_macro, user_id: @user.id)
    @meso  = create(:act_meso, user_id: @user.id)
    @micro = create(:act_micro, user_id: @user.id)
    @actor = create(:actor_macro, acts: [@macro, @meso, @micro])
  end

  it 'Create Relation act actor' do
    expect(@macro.name).to eq('First one')
    expect(@actor.name).to eq('Organization one')
    expect(Actor.count).to eq(1)
    expect(Act.count).to eq(3)
    expect(@micro.actors.count).to eq(1)
    expect(@macro.actors.count).to eq(1)
    expect(@micro.actor_mesos.count).to eq(0)
    expect(@macro.actor_micros.count).to eq(0)
    expect(ActActorRelation.count).to eq(3)
  end

  it 'Delete Relation macro actor' do
    @macro.destroy
    expect(ActActorRelation.count).to eq(2)
    expect(@actor.act_macros.count).to eq(0)
  end

  it 'Get actors for macro, meso and micro acts' do
    expect(@actor.acts.count).to eq(3)
    expect(@actor.act_macros.count).to eq(1)
    expect(@actor.act_mesos.count).to eq(1)
    expect(@actor.act_micros.count).to eq(1)
  end

  it 'Get relations dates' do
    @relation = ActActorRelation.last.update_attributes(end_date: Time.zone.now, start_date: Time.zone.now - 30.years)
    expect(ActActorRelation.get_dates(@micro, @actor)).to eq(["September  1, 1985", "September  1, 2015"])
  end

  it 'Get relations start_date' do
    @relation = ActActorRelation.last.update_attributes(start_date: Time.zone.now - 30.years)
    expect(ActActorRelation.get_dates(@micro, @actor)).to eq(["September  1, 1985", nil])
  end

  it 'Get relations end_date' do
    @relation = ActActorRelation.last.update_attributes(end_date: Time.zone.now)
    expect(ActActorRelation.get_dates(@micro, @actor)).to eq([nil, "September  1, 2015"])
  end
end
