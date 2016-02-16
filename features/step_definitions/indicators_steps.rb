Then /^I should have zero indicators$/ do
  Indicator.all.size.should == 0
end

Then /^I should have one indicator$/ do
  Indicator.all.size.should >= 1
end

Then /^I should have two indicators$/ do
  Indicator.all.size.should >= 2
end

Then /^I should have two tags$/ do
  Tag.all.size.should == 2
end

Then /^I should have indicator with measurements$/ do
  Indicator.last.act_indicator_relations.last.measurements.size.should == 0
end

Given /^indicator$/ do
  FactoryGirl.create(:indicator, user_id: User.last.id)
end

Given /^indicator with action relations$/ do
  @user = FactoryGirl.create(:user)
  @act  = FactoryGirl.create(:act_macro, user_id: @user.id)
  FactoryGirl.create(:indicator, name: 'Indicator one with relation', user: @user, acts: [@act])
end

Given /^indicator by admin$/ do
  @admin = FactoryGirl.create(:adminuser)
  FactoryGirl.create(:admin)
  FactoryGirl.create(:indicator, name: 'Indicator by admin', user: @admin)
end

Given /^act_indicator_relation_types$/ do
  FactoryGirl.create(:act_indicator_relation_type_belongs)
end
