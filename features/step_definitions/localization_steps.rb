Then /^I should have a localization$/ do
  Localization.all.size.should >= 1
end

Given /^organization_localization$/ do
  FactoryGirl.create(:localization, actors: [Actor.last], user_id: User.last.id)
end

Given /^act_localization$/ do
  FactoryGirl.create(:localization, acts: [Act.last], user_id: User.last.id)
end

Given /^user organization with localization$/ do
  @user = FactoryGirl.create(:user)
  @actor = FactoryGirl.create(:actor_macro, name: 'Organization by user', user: @user)
  FactoryGirl.create(:localization, actors: [@actor], user: @user)
end

Given /^user act with localization$/ do
  @user = FactoryGirl.create(:user)
  @act = FactoryGirl.create(:act_macro, name: 'First act by user', user: @user)
  FactoryGirl.create(:localization, acts: [@act], user: @user)
end