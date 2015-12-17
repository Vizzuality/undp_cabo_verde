require 'spec_helper'

RSpec.describe Ability, type: :model do
  before :each do
    @adminuser = create(:adminuser)
    @user = create(:random_user)
  end

  it { Abilities::AdminUser.should include(CanCan::Ability) }
  it { Abilities::AdminUser.should respond_to(:new).with(1).argument }

  it { Abilities::User.should include(CanCan::Ability) }
  it { Abilities::User.should respond_to(:new).with(1).argument }

  it { Abilities::Guest.should include(CanCan::Ability) }
  it { Abilities::Guest.should respond_to(:new).with(1).argument }

  context 'admin' do
    it 'can manage objects' do
      [User, Actor, ActorMicro, ActorMeso, ActorMacro, ActorRelation, Act, ActMicro, ActMeso, 
       ActMacro, ActRelation, Localization, Category, Comment, RelationType, Unit,
       Indicator, ActActorRelation, ActIndicatorRelation, Measurement].each do |model|
        Abilities::AdminUser.any_instance.should_receive(:can).with(:manage, model)
      end
      Abilities::AdminUser.any_instance.should_receive(:can).with([:activate, :deactivate], Localization)
      Abilities::AdminUser.any_instance.should_receive(:can).with([:activate, :deactivate], Comment)
      Abilities::AdminUser.any_instance.should_receive(:cannot).with(:make_user, User, id: @adminuser.id)
      Abilities::AdminUser.any_instance.should_receive(:cannot).with([:activate, :deactivate], User, id: @adminuser.id)

      Abilities::AdminUser.any_instance.should_receive(:can).with(:read, :all)
      Abilities::AdminUser.new @adminuser
    end
  end

  context 'user' do
    it 'can manage objects' do
      [User].each do |model|
        Abilities::User.any_instance.should_receive(:can).with(:update, model, id: @user.id)
      end
      [Actor, ActorMicro, ActorMeso, ActorMacro, ActorRelation, Act, ActMicro, 
       ActMeso, ActMacro, ActRelation, Localization, Comment,
       Indicator, ActActorRelation, ActIndicatorRelation, Measurement].each do |model|
        Abilities::User.any_instance.should_receive(:can).with(:manage, model, user_id: @user.id)
      end
      Abilities::User.any_instance.should_receive(:can).with([:activate, :deactivate], Comment, user_id: @user.id)
      Abilities::User.any_instance.should_receive(:can).with(:dashboard, User)
      Abilities::User.any_instance.should_receive(:cannot).with([:activate, :deactivate], Localization)

      Abilities::User.any_instance.should_receive(:can).with(:read, :all)
      Abilities::User.any_instance.should_receive(:cannot).with(:read, RelationType)
      Abilities::User.new @user
    end
  end

  context 'guest' do
    it 'can read objects' do
      Abilities::Guest.any_instance.should_receive(:can).with(:read, :all)
      Abilities::Guest.any_instance.should_receive(:cannot).with(:read, RelationType)
      Abilities::Guest.new @user
    end
  end
end
