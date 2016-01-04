Then /^I should not have units$/ do
  Unit.all.size.should == 0
end

Then /^I should have an unit$/ do
  Unit.all.size.should >= 1
end

Given /^unit by authenticated user$/ do
  @user = FactoryGirl.create(:user)
  FactoryGirl.create(:unit, user: @user)
  email = @user.email
  password = @user.password
  visit '/account/login'
  fill_in "user_email", with: email
  fill_in "user_password", with: password
  click_button "Log in"
end

Given /^unit by user$/ do
  @user = FactoryGirl.create(:user)
  FactoryGirl.create(:unit, user: @user)
end

Given /^unit by admin user$/ do
  @user = FactoryGirl.create(:adminuser)
  FactoryGirl.create(:admin, user: @user)
  FactoryGirl.create(:unit, user: @user)
end