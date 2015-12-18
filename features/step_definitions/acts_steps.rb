Then /^I should have zero acts$/ do
  Act.all.size.should == 0
end

Then /^I should have one act$/ do
  Act.all.size.should >= 1
end

Then /^I should have two acts$/ do
  Act.all.size.should >= 2
end

Then /^I should not have indicators$/ do
  Act.last.indicators.all.size.should == 0
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

Given /^action with relations$/ do
  @user = FactoryGirl.create(:user)
  @meso = FactoryGirl.create(:act_meso, user_id: @user.id)
  FactoryGirl.create(:act_micro, name: 'Action one', user_id: User.last.id, parents: [@meso])
end

Given /^action with actor relations$/ do
  @user = FactoryGirl.create(:user)
  @actor  = FactoryGirl.create(:actor_macro, user_id: @user.id)
  FactoryGirl.create(:act_micro, name: 'Action one with relation', user: @user, actors: [@actor])
end

Given /^first act by admin$/ do
  @admin = FactoryGirl.create(:adminuser)
  FactoryGirl.create(:admin)
  FactoryGirl.create(:act_macro, name: 'First act by admin', user: @admin)
end

Given /^act_relation_types$/ do
  FactoryGirl.create(:acts_relation_type)
end

Given /^unit$/ do
  FactoryGirl.create(:unit)
end

Given /^action with indicator relations$/ do
  @user = FactoryGirl.create(:user)
  @act  = FactoryGirl.create(:act_macro, name: 'Action with indicator', user_id: @user.id)
  FactoryGirl.create(:indicator, name: 'Indicator one with relation', user: @user, acts: [@act])
end

Given /^action with indicator relations and measurement$/ do
  @unit      = FactoryGirl.create(:unit)
  @user      = FactoryGirl.create(:user)
  @act       = FactoryGirl.create(:act_macro, name: 'Action with indicator and measurement', user_id: @user.id)
  @act.reload
  @indicator = FactoryGirl.create(:indicator, name: 'Indicator one with relation', user: @user, acts: [@act])
  @indicator.reload
  @act_indicator = ActIndicatorRelation.find_by(indicator_id: @indicator.id)
  FactoryGirl.create(:measurement, user_id: @user.id, act_indicator_relation_id: @act_indicator.id, unit_id: @unit.id)
end

Then /^I should not have act indicator relation with measurements for "([^"]*)"$/ do |name|
  @act = Act.find_by_name(name)
  @act.act_indicator_relations.last.reload
  @act.act_indicator_relations.last.measurements.size.should == 0
end

Then /^I should have act indicator relation with one measurement for "([^"]*)"$/ do |name|
  @act = Act.find_by_name(name)
  @act.act_indicator_relations.last.reload
  @act.act_indicator_relations.last.measurements.size.should == 1
end

