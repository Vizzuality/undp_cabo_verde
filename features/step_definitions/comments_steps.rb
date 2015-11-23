Given(/^first act by admin with comment$/) do
  @admin = FactoryGirl.create(:adminuser)
  FactoryGirl.create(:admin)
  @comment = FactoryGirl.create(:comment, user: @admin)
  FactoryGirl.create(:act_macro, name: 'Comment on first act by admin', user: @admin, comments: [@comment])
end

Given(/^first act by user with comment$/) do
  @user = FactoryGirl.create(:user)
  @comment = FactoryGirl.create(:comment, user: @user)
  FactoryGirl.create(:act_macro, name: 'Comment on first act by user', user: @user, comments: [@comment])
end

Given(/^first act by auth user with comment$/) do
  @user = User.last
  @comment = FactoryGirl.create(:comment, user: @user)
  FactoryGirl.create(:act_macro, name: 'Comment on first act by user', user: @user, comments: [@comment])
end