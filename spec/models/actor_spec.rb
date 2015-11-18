require 'rails_helper'

RSpec.describe Actor, type: :model do
  before :each do
    @user  = create(:user)
    @macro = create(:actor_macro, user_id: @user.id)
    @meso  = create(:actor_meso, user_id: @user.id, parents: [@macro])
    @micro = create(:actor_micro, user_id: @user.id, parents: [@macro, @meso], gender: 2, title: 2, date_of_birth: Time.zone.now - 30.years)
    @relation = ActorRelation.find_by(parent_id: @meso.id, child_id: @micro.id)
  end

  it 'Create ActorMacro' do
    expect(@macro.name).to eq('Organization one')
    expect(@macro.mesos.first.name).to eq('Department one')
    expect(@macro.micros.first.name).to eq('Person one')
    expect(@macro.macro?).to eq(true)
    expect(@macro.operational_filed_txt).to eq('Global')
  end

  it 'Create ActorMeso' do
    expect(@meso.name).to eq('Department one')
    expect(@meso.micros.first.name).to eq('Person one')
    expect(@meso.macros_parents.first.name).to eq('Organization one')
    expect(@meso.meso?).to eq(true)
  end

  it 'Create ActorMicro' do
    expect(@micro.name).to eq('Person one')
    expect(@micro.macros_parents.first.name).to eq('Organization one')
    expect(@micro.mesos_parents.first.name).to eq('Department one')
    expect(@micro.micro?).to eq(true)
    expect(@micro.gender_txt).to eq('Male')
    expect(@micro.title_txt).to eq('Ms')
    expect(@micro.birth).to eq((Time.zone.now - 30.years).to_date)
  end

  it 'order actor by name' do
    expect(Actor.order(name: :asc)).to eq([@meso, @macro, @micro])
    expect(Actor.count).to eq(3)
    expect(ActorMicro.count).to eq(1)
    expect(ActorMeso.count).to eq(1)
    expect(ActorMacro.count).to eq(1)
  end

  it 'actor name validation' do
    @person_reject = ActorMicro.new(name: '', user_id: @user.id)

    @person_reject.valid?
    expect {@person_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it 'actor with actor type' do
    expect(@micro.type).to eq('ActorMicro')
  end

  it 'actor with user' do
    expect(@micro.user.name).to eq('Pepe Moreno')
    expect(@user.actors.count).to eq(3)
    expect(@user.actor_micros.count).to eq(1)
    expect(@user.actor_macros.count).to eq(1)
    expect(@user.actor_mesos.count).to eq(1)
    expect(@micro.micro_or_meso?).to eq(true)
  end

  it 'Deactivate activate actor' do
    @micro.deactivate
    expect(ActorMicro.count).to eq(1)
    expect(ActorMicro.filter_inactives.count).to eq(1)
    expect(@micro.deactivated?).to be(true)
    @micro.activate
    expect(@micro.activated?).to be(true)
    expect(ActorMicro.filter_actives.count).to be(1)
  end

  context 'Add actions to actor' do
    before :each do
      @action_micro = create(:action_micro, user_id: @user.id, actors: [@macro])
      @action_meso = create(:action_meso, user_id: @user.id, actors: [@macro])
      @action_macro = create(:action_macro, user_id: @user.id, actors: [@macro])
    end

    it 'Get actions macro meso micro for actor' do
      expect(@macro.actions.count).to eq(3)
      expect(@macro.action_macros.count).to eq(1)
      expect(@macro.action_mesos.count).to eq(1)
      expect(@macro.action_micros.count).to eq(1)
    end
  end
end
