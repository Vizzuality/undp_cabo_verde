require 'rails_helper'

RSpec.describe Ability, type: :model do
  before :each do
    @adminuser   = create(:adminuser)
    @manageruser = create(:random_user)
    @user        = create(:random_public_user)
  end

  it { Abilities::AdminUser.should include(CanCan::Ability) }
  it { Abilities::AdminUser.should respond_to(:new).with(1).argument }

  it { Abilities::ManagerUser.should include(CanCan::Ability) }
  it { Abilities::ManagerUser.should respond_to(:new).with(1).argument }

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
      Abilities::AdminUser.any_instance.should_receive(:cannot).with(:make_manager, User, id: @adminuser.id)
      Abilities::AdminUser.any_instance.should_receive(:cannot).with(:make_user, User, id: @adminuser.id)
      Abilities::AdminUser.any_instance.should_receive(:cannot).with([:activate, :deactivate], User, id: @adminuser.id)

      Abilities::AdminUser.any_instance.should_receive(:can).with(:read, :all)
      Abilities::AdminUser.new @adminuser
    end
  end

  context 'manager' do
    it 'can manage objects' do
      [User].each do |model|
        Abilities::ManagerUser.any_instance.should_receive(:can).with(:update, model, id: @manageruser.id)
      end
      [Actor, ActorMicro, ActorMeso, ActorMacro, ActorRelation, Act, ActMicro,
       ActMeso, ActMacro, ActRelation, Localization, Comment,
       Indicator, ActActorRelation, ActIndicatorRelation, Measurement, Unit].each do |model|
        Abilities::ManagerUser.any_instance.should_receive(:can).with(:manage, model, user_id: @manageruser.id)
      end
      Abilities::ManagerUser.any_instance.should_receive(:can).with([:activate, :deactivate], Comment, user_id: @manageruser.id)
      Abilities::ManagerUser.any_instance.should_receive(:can).with(:dashboard, User)
      Abilities::ManagerUser.any_instance.should_receive(:can).with(:create, OtherDomain)
      Abilities::ManagerUser.any_instance.should_receive(:cannot).with([:activate, :deactivate], Localization)

      Abilities::ManagerUser.any_instance.should_receive(:can).with(:read, :all)
      Abilities::ManagerUser.any_instance.should_receive(:cannot).with(:make_user, User, id: @manageruser.id)
      Abilities::ManagerUser.any_instance.should_receive(:cannot).with(:read, RelationType)
      Abilities::ManagerUser.new @manageruser
    end
  end

  context 'user' do
    it 'can manage objects' do
      [User].each do |model|
        Abilities::User.any_instance.should_receive(:can).with(:update, model, id: @user.id)
      end
      [Comment].each do |model|
        Abilities::User.any_instance.should_receive(:can).with(:manage, model, user_id: @user.id)
      end
      Abilities::User.any_instance.should_receive(:can).with([:activate, :deactivate], Comment, user_id: @user.id)
      Abilities::User.any_instance.should_receive(:can).with(:dashboard, User)
      Abilities::User.any_instance.should_receive(:can).with(:read, User, id: @user.id)
      Abilities::User.new @user
    end
  end

  context 'guest' do
    it 'can read objects' do
      Abilities::Guest.new @user
    end
  end
end
