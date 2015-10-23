Then /^I should have an user$/ do
  User.all.size.should >= 1
end

Then /^I should have an adminuser$/ do
  AdminUser.all.size.should >= 1
end

Then /^I should have one adminuser$/ do
  AdminUser.all.size.should == 1
end

Then /^I should have two adminusers$/ do
  AdminUser.all.size.should == 2
end

Given /^I am authenticated user$/ do
  @user = FactoryGirl.create(:user)
  email = @user.email
  password = @user.password
  visit '/account/login'
  fill_in "user_email", with: email
  fill_in "user_password", with: password
  click_button "Log in"
end

Given /^I am authenticated adminuser$/ do
  @user = FactoryGirl.create(:adminuser)
  FactoryGirl.create(:admin)
  email = @user.email
  password = @user.password
  visit '/account/login'
  fill_in "user_email", with: email
  fill_in "user_password", with: password
  click_button "Log in"
end

Given /^I am registrated user$/ do
  @user = FactoryGirl.create(:user, email: 'test-user@sample.com', password: 'password')
end

Given /^user$/ do
  FactoryGirl.create(:user)
end

Given /^adminuser$/ do
  FactoryGirl.create(:adminuser)
  FactoryGirl.create(:admin)
end