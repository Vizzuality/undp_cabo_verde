Then /^I should have zero actors$/ do
  Actor.all.size.should == 0
end

Then /^I should have one actor$/ do
  Actor.all.size.should >= 1
end

Then /^I should have two actors$/ do
  AdminUser.all.size.should >= 2
end

Given /^actor$/ do
  FactoryGirl.create(:person, user_id: User.last.id)
end

Given /^person$/ do
  FactoryGirl.create(:person, user_id: User.last.id)
end

Given /^organization by admin$/ do
  @admin = FactoryGirl.create(:adminuser)
  FactoryGirl.create(:admin)
  FactoryGirl.create(:organization, user: @admin)
end