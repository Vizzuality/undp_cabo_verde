Then /^I should have zero actors$/ do
  Actor.all.size.should == 0
end

Then /^I should have one actor$/ do
  Actor.all.size.should >= 1
end

Then /^I should have two actors$/ do
  AdminUser.all.size.should >= 2
end

Then /^I should have one micro_meso$/ do
  MesoMicroRelation.all.size.should >= 1
end

Then /^I should have one micro_macro$/ do
  MacroMicroRelation.all.size.should >= 1
end

Then /^I should have one meso_macro$/ do
  MacroMesoRelation.all.size.should >= 1
end

Given /^actor$/ do
  FactoryGirl.create(:actor_micro, user_id: User.last.id)
end

Given /^person$/ do
  FactoryGirl.create(:actor_micro, user_id: User.last.id)
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
  FactoryGirl.create(:actor_macro, user: @admin)
end