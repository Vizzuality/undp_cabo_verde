Then /^I should have a localization$/ do
  Localization.all.size.should >= 1
end

Given /^organization_localization$/ do
  FactoryGirl.create(:localization, actors: [Actor.last])
end