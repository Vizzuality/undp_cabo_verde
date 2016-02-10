require 'rails_helper'

RSpec.describe Act, type: :model do
  before :each do
    @user  = create(:user)
    @macro = create(:act_macro, user_id: @user.id)
    @meso  = create(:act_meso, user_id: @user.id, parents: [@macro])
    @micro = create(:act_micro, user_id: @user.id, parents: [@macro, @meso], end_date: Time.zone.now, start_date: Time.zone.now - 30.years)
    @relation = ActRelation.find_by(parent_id: @meso.id, child_id: @micro.id)
  end

  it 'Create ActMacro' do
    expect(@macro.name).to eq('First one')
    expect(@macro.mesos.first.name).to eq('Second one')
    expect(@macro.micros.first.name).to eq('Third one')
    expect(@macro.macro?).to eq(true)
  end

  it 'Create ActMeso' do
    expect(@meso.name).to eq('Second one')
    expect(@meso.micros.first.name).to eq('Third one')
    expect(@meso.macros_parents.first.name).to eq('First one')
    expect(@meso.meso?).to eq(true)
  end

  it 'Create ActMicro' do
    expect(@micro.name).to eq('Third one')
    expect(@micro.macros_parents.first.name).to eq('First one')
    expect(@micro.mesos_parents.first.name).to eq('Second one')
    expect(@micro.micro?).to eq(true)
    expect(@micro.startdate).to eq((Time.zone.now - 30.years).to_date)
    expect(@micro.enddate).to eq(Time.zone.now.to_date)
  end

  it 'order act by name' do
    expect(Act.order(name: :asc)).to eq([@macro, @meso, @micro])
    expect(Act.count).to eq(3)
    expect(ActMicro.count).to eq(1)
    expect(ActMeso.count).to eq(1)
    expect(ActMacro.count).to eq(1)
  end

  it 'act name validation' do
    @act_reject = build(:act_micro, name: '', user_id: @user.id)

    @act_reject.valid?
    expect {@act_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  context "act domain validation" do
    it 'act domain validation min 1 domain' do
      @act_reject = build(:act_micro, socio_cultural_domains: [], user_id: @user.id)

      @act_reject.valid?
      expect {@act_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Socio cultural domain ids can't be blank, Other domain ids can't be blank")
    end

    it 'act domain validation max 3 domains' do
      @cat_1 = create(:operational_field, name: 'Cat 1')
      @cat_2 = create(:operational_field, name: 'Cat 2')
      @cat_3 = create(:operational_field, name: 'Cat 3')
      @cat_4 = create(:operational_field, name: 'Cat 4')
      @act_reject = build(:act_micro, socio_cultural_domains: [@cat_1, @cat_2, @cat_3, @cat_4], user_id: @user.id)

      @act_reject.valid?
      expect {@act_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Socio cultural domains is too long (maximum is 3 characters)")
    end
  end

  it 'act with act type' do
    expect(@micro.type).to eq('ActMicro')
  end

  it 'act with user' do
    expect(@micro.user.name).to eq('Pepe Moreno')
    expect(@user.acts.count).to eq(3)
    expect(@user.act_micros.count).to eq(1)
    expect(@user.act_macros.count).to eq(1)
    expect(@user.act_mesos.count).to eq(1)
    expect(@micro.micro_or_meso?).to eq(true)
  end

  it 'Deactivate activate act' do
    @micro.deactivate
    expect(ActMicro.count).to eq(1)
    expect(ActMicro.filter_inactives.count).to eq(1)
    expect(@micro.deactivated?).to be(true)
    @micro.activate
    expect(@micro.activated?).to be(true)
    expect(ActMicro.filter_actives.count).to be(1)
  end

  context 'Add actors to acts' do
    before :each do
      @actor_micro = create(:actor_micro, user_id: @user.id, acts: [@macro])
      @actor_meso = create(:actor_meso, user_id: @user.id, acts: [@macro])
      @actor_macro = create(:actor_macro, user_id: @user.id, acts: [@macro])
    end

    it 'Get actors macro meso micro for act' do
      expect(@macro.actors.count).to eq(3)
      expect(@macro.actor_macros.count).to eq(1)
      expect(@macro.actor_mesos.count).to eq(1)
      expect(@macro.actor_micros.count).to eq(1)
    end
  end
end
