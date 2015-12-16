Feature: Categories
In order to manage categories
As a adminuser
I want to manage a category

  Scenario: User can not view categories page and category page without login
    Given category
    When I go to the categories page
    And I should see "You need to sign in or sign up before continuing."
    Then I should be on the login page

  Scenario: Anyone can view categories tree
    Given category_tree
    And I am authenticated user
    When I go to the categories page
    Then I should be on the categories page
    And I should see "Category one"
    And I should see "Category two" within ".sub-category_2"
    And I should see "Category three" within ".sub-category_3"

  Scenario: User can view category
    Given I am authenticated user
    And category
    When I go to the category page for "Category one"
    Then I should be on the category page for "Category one"
    And I should see "Category one"

  Scenario: Adminuser can edit category
    Given I am authenticated adminuser
    And category
    And category_two
    And category_three
    When I go to the edit category page for "Category one"
    And I fill in "other_domain_name" with "Category new name"
    # And I select "Category two" from "other_domain_parent_id"
    # And I check "Category three"
    And I press "Update"
    Then I should be on the categories page
    And I should see "Category new name"
    # When I go to the category page for "Category new name"
    # Then I should see "Category two"
    # And I should see "Category three"

  Scenario: User can create category for owned actor
    Given I am authenticated adminuser
    And category_two
    And category_three
    When I go to the new category page
    And I select "Organization type" from "category_type"
    And I fill in "category_name" with "Category new name"
    # And I select "Category two" from "category_parent_id"
    # And I check "Category three"
    And I press "Create"
    Then I should have three categories
    Then I go to the category page for "Category new name"
    # Then I should see "Category two"
    # And I should see "Category three"

  Scenario: Adminuser can not edit category without name
    Given I am authenticated adminuser
    And category
    When I go to the edit category page for "Category one"
    And I fill in "other_domain_name" with ""
    And I press "Update"
    Then I should see "Please review the problems below:"
    And I should see "can't be blank"

  Scenario: Adminuser can delete category
    Given I am authenticated adminuser
    And category
    When I go to the edit category page for "Category one"
    And I follow "Delete"
    Then I should have zero categories
    