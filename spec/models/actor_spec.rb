require 'rails_helper'

RSpec.describe Actor, type: :model do

  before :each do
    @user         = create(:user)
    @person       = create(:person, user_id: @user.id)
    @organization = create(:organization, user_id: @user.id)
  end

  it "create actor" do
    expect(@person.title).to eq('Person one')
    expect(@organization.title).to eq('Organization one')
  end

  it "order actor by name" do
    expect(Actor.order(title: :asc)).to eq([@organization, @person])
    expect(Actor.count).to eq(2)
    expect(Person.count).to eq(1)
    expect(Organization.count).to eq(1)
  end

  it "actor without title - title validation" do
    @person_reject = Person.new(type: 'Person', title: '', user_id: @user.id)

    @person_reject.valid?
    expect {@person_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Title can't be blank")
  end

  it "actor with actor type" do
    expect(@person.type).to eq('Person')
  end

  it "actor with user" do
    expect(@person.user.name).to eq('Pepe Moreno')
    expect(@user.actors.count).to eq(2)
    expect(@user.persons.count).to eq(1)
    expect(@user.organizations.count).to eq(1)
  end

  it "Organization without description created on Actor model" do
    @person_actor = create(:person_actor, title: 'test person_actor without description', description: nil)

    expect(@person_actor.title).to eq('test person_actor without description')
    expect(@person_actor.description).to be_nil
  end

  it "Deactivate activate actor" do
    @person.deactivate
    expect(Person.count).to eq(1)
    expect(Person.filter_inactives.count).to eq(1)
    expect(@person.deactivated?).to be(true)
    @person.activate
    expect(@person.activated?).to be(true)
    expect(Person.filter_actives.count).to be(1)
  end

end
