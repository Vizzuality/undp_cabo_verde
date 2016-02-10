require 'rails_helper'

RSpec.describe Actor, type: :model do
  before :each do
    @user     = create(:user)
    @field    = create(:operational_field, name: 'Global')
    @domain   = create(:category, name: 'Category one', type: 'SocioCulturalDomain')
    @macro    = create(:actor_macro, user_id: @user.id, operational_field: @field.id)
    @localization = create(:localization, name: 'First Localization', user: @user, main: true, localizable: @macro)
    @meso     = create(:actor_meso, user_id: @user.id, parents: [@macro])
    @micro    = create(:actor_micro, user_id: @user.id, parents: [@macro, @meso], gender: 2, title: 2)
    @relation = ActorRelation.find_by(parent_id: @meso.id, child_id: @micro.id)
  end

  it 'Create ActorMacro' do
    expect(@macro.name).to eq('Organization one')
    expect(@macro.mesos.first.name).to eq('Department one')
    expect(@macro.micros.first.name).to eq('Person one')
    expect(@macro.macro?).to eq(true)
    expect(@macro.operational_field_txt).to match('Global')
    expect(@macro.localizations.count).to eq(1)
    expect(@macro.main_country).to eq('Cape Verde')
  end

  it 'Create ActorMeso' do
    expect(@meso.name).to eq('Department one')
    expect(@meso.micros.first.name).to eq('Person one')
    expect(@meso.macros_parents.first.name).to eq('Organization one')
    expect(@meso.meso?).to eq(true)
  end

  it 'Create ActorMicro' do
    actor = ActorMicro.create(name: 'Test', socio_cultural_domains: [@domain], user_id: @user.id, parents: [@macro, @meso], gender: 2, title: 2)
    actor.save!
    expect(actor.name).to eq('Test')
    expect(actor.macros_parents.first.name).to eq('Organization one')
    expect(actor.mesos_parents.first.name).to eq('Department one')
    expect(actor.micro?).to eq(true)
    expect(actor.gender_txt).to eq('Male')
    expect(actor.title_txt).to eq('Ms.')
    # after_commit rspec broken on rails 4
    # expect(actor.parent_location_id).to eq(@localization.id)
  end

  it 'order actor by name' do
    expect(Actor.order(name: :asc)).to eq([@meso, @macro, @micro])
    expect(Actor.count).to eq(3)
    expect(ActorMicro.count).to eq(1)
    expect(ActorMeso.count).to eq(1)
    expect(ActorMacro.count).to eq(1)
  end

  it 'actor name validation' do
    @person_reject = build(:actor_micro, name: '', user_id: @user.id)

    @person_reject.valid?
    expect {@person_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  context "actor domain validation" do
    it 'actor domain validation min 1 domain' do
      @person_reject = build(:actor_micro, socio_cultural_domains: [], user_id: @user.id)

      @person_reject.valid?
      expect {@person_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Socio cultural domain ids can't be blank, Other domain ids can't be blank")
    end

    it 'actor domain validation max 3 domains' do
      @cat_1 = create(:operational_field, name: 'Cat 1')
      @cat_2 = create(:operational_field, name: 'Cat 2')
      @cat_3 = create(:operational_field, name: 'Cat 3')
      @cat_4 = create(:operational_field, name: 'Cat 4')
      @person_reject = build(:actor_micro, socio_cultural_domains: [@cat_1, @cat_2, @cat_3, @cat_4], user_id: @user.id)

      @person_reject.valid?
      expect {@person_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Socio cultural domains is too long (maximum is 3 characters)")
    end
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

  context 'Add acts to actor' do
    before :each do
      @act_micro = create(:act_micro, user_id: @user.id, actors: [@macro])
      @act_meso = create(:act_meso, user_id: @user.id, actors: [@macro])
      @act_macro = create(:act_macro, user_id: @user.id, actors: [@macro])
    end

    it 'Get acts macro meso micro for actor' do
      expect(@macro.acts.count).to eq(3)
      expect(@macro.act_macros.count).to eq(1)
      expect(@macro.act_mesos.count).to eq(1)
      expect(@macro.act_micros.count).to eq(1)
    end
  end
end
