Then /^I should have zero acts$/ do
  Act.all.size.should == 0
end

Then /^I should have one act$/ do
  Act.all.size.should >= 1
end

Then /^I should have two acts$/ do
  AdminUser.all.size.should >= 2
end

Given /^act$/ do
  FactoryGirl.create(:act_micro, user_id: User.last.id)
end

Given /^third act$/ do
  FactoryGirl.create(:act_micro, user_id: User.last.id)
end

Given /^second act$/ do
  FactoryGirl.create(:act_meso, user_id: User.last.id)
end

Given /^first act$/ do
  FactoryGirl.create(:act_macro, user_id: User.last.id)
end

Given /^first act by admin$/ do
  @admin = FactoryGirl.create(:adminuser)
  FactoryGirl.create(:admin)
  FactoryGirl.create(:act_macro, name: 'First act by admin', user: @admin)
end