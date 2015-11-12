Then /^I should have one category$/ do
  Category.all.size.should >= 1
end

Then /^I should have three categories$/ do
  Category.all.size.should >= 3
end

Then /^I should have zero categories$/ do
  Category.all.size.should == 0
end

Given /^category$/ do
  FactoryGirl.create(:category)
end

Given /^category_two$/ do
  FactoryGirl.create(:category, name: 'Category two')
end

Given /^category_three$/ do
  FactoryGirl.create(:category, name: 'Category three')
end

Given /^category_tree$/ do
  @cat_1 = FactoryGirl.create(:category, id: 2, name: 'Category two')
  @cat_2 = FactoryGirl.create(:category, id: 3, name: 'Category three')
  FactoryGirl.create(:category, id: 1, children: [@cat_1, @cat_2])
end