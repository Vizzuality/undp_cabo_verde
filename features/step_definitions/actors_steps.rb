Then /^I should have zero actors$/ do
  Actor.all.size.should == 0
end

Then /^I should have one actor$/ do
  Actor.all.size.should >= 1
end

Then /^I should have one actor meso$/ do
  ActorMeso.all.size.should >= 1
end

Then /^I should have two actors$/ do
  Actor.all.size.should >= 2
end

Given /^actor$/ do
  FactoryGirl.create(:actor_micro, user_id: User.last.id)
end

Given /^person$/ do
  FactoryGirl.create(:actor_micro, user_id: User.last.id)
end

Given /^actor with relations$/ do
  @user = FactoryGirl.create(:user)
  @meso = FactoryGirl.create(:actor_meso, user_id: @user)
  FactoryGirl.create(:actor_micro, name: 'Person one with relation', user: @user, parents: [@meso])
end

Given /^actor with action relations$/ do
  @user = FactoryGirl.create(:user)
  @act  = FactoryGirl.create(:act_macro, user_id: @user.id)
  FactoryGirl.create(:actor_micro, name: 'Person one with relation', user: @user, acts: [@act])
end

Given /^department$/ do
  FactoryGirl.create(:actor_meso, user_id: User.last.id)
end

Given /^organization$/ do
  FactoryGirl.create(:actor_macro, user_id: User.last.id)
end

Given /^organization by admin$/ do
  @admin = FactoryGirl.create(:adminuser)
  FactoryGirl.create(:admin)
  FactoryGirl.create(:actor_macro, name: 'Organization by admin', user: @admin)
end

Given /^relation_types$/ do
  FactoryGirl.create(:actors_relation_type_belongs)
end

Given /^act_actor_relation_types$/ do
  FactoryGirl.create(:act_actor_relation_type)
end
