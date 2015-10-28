require 'rails_helper'

RSpec.describe Actor, type: :model do

  before :each do
    @user  = create(:user)
    @macro = create(:actor_macro, user_id: @user.id)
    @meso  = create(:actor_meso, user_id: @user.id, macros: [@macro])
    @micro = create(:actor_micro, user_id: @user.id, mesos: [@meso], macros: [@macro])
  end

  it "Create ActorMacro" do
    expect(@macro.name).to eq('Organization one')
    expect(@macro.mesos.first.name).to eq('Department one')
    expect(@macro.micros.first.name).to eq('Person one')
  end

  it "Create ActorMeso" do
    expect(@meso.name).to eq('Department one')
    expect(@meso.micros.first.name).to eq('Person one')
    expect(@meso.macros.first.name).to eq('Organization one')
  end

  it "Create ActorMicro" do
    expect(@micro.name).to eq('Person one')
    expect(@micro.macros.first.name).to eq('Organization one')
    expect(@micro.mesos.first.name).to eq('Department one')
  end

  it "order actor by name" do
    expect(Actor.order(name: :asc)).to eq([@meso, @macro, @micro])
    expect(Actor.count).to eq(3)
    expect(ActorMicro.count).to eq(1)
    expect(ActorMeso.count).to eq(1)
    expect(ActorMacro.count).to eq(1)
  end

  it "actor without name - name validation" do
    @person_reject = ActorMicro.new(name: '', user_id: @user.id)

    @person_reject.valid?
    expect {@person_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it "actor with actor type" do
    expect(@micro.type).to eq('ActorMicro')
  end

  it "actor with user" do
    expect(@micro.user.name).to eq('Pepe Moreno')
    expect(@user.actors.count).to eq(3)
    expect(@user.actor_micros.count).to eq(1)
    expect(@user.actor_macros.count).to eq(1)
    expect(@user.actor_mesos.count).to eq(1)
  end

  it "Deactivate activate actor" do
    @micro.deactivate
    expect(ActorMicro.count).to eq(1)
    expect(ActorMicro.filter_inactives.count).to eq(1)
    expect(@micro.deactivated?).to be(true)
    @micro.activate
    expect(@micro.activated?).to be(true)
    expect(ActorMicro.filter_actives.count).to be(1)
  end

end
