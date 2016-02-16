Feature: Indicators
In order to manage indicators
As an adminuser
I want to manage an indicator

  Scenario: User can not view indicators page and indicator page without login
    Given user
    And indicator
    And indicator by admin
    When I go to the indicators page
    Then I should see "You need to sign in or sign up before continuing."
    And I should be on the login page

  Scenario: User can edit owned indicator
    Given I am authenticated user
    And indicator
    When I go to the edit indicator page for "Indicator one"
    And I fill in "indicator_name" with "New Indicator"
    And I fill in "indicator_description" with "It's description for indicator"
    And I fill in "indicator_alternative_name" with "It's name for indicator"
    And I press "Update"
    Then I should be on the indicator page for "New Indicator"
    And the disabled field "Name" should contain "New Indicator"
    And the disabled field "Alternative name" should contain "It's name for indicator"
    And the disabled field "Description" should contain "It's description for indicator"

  Scenario: Adminuser can edit not owned indicator
    Given user
    And indicator
    And I am authenticated adminuser
    When I go to the edit indicator page for "Indicator one"
    Then I should be on the edit indicator page for "Indicator one"
    When I fill in "indicator_name" with "New Indicator"
    And I press "Update"
    Then I should be on the indicator page for "New Indicator"
    And the disabled field "Name" should contain "New Indicator"

  Scenario: User can create indicator
    Given I am authenticated adminuser
    When I go to the new indicator page
    And I fill in "indicator_name" with "New Indicator"
    And I fill in "indicator_description" with "It's description for indicator"
    And I fill in "indicator_alternative_name" with "It's name for indicator"
    And I press "Create"
    Then I should have one indicator
    And I should be on the indicator page for "New Indicator"

  Scenario: User can not edit not owned indicator
    Given I am authenticated user
    And indicator by admin
    When I go to the edit indicator page for "Indicator by admin"
    Then I should be on the home page
    And I should see "You are not authorized to access this page."

  Scenario: Adminuser can remove not owned indicator
    Given user
    And indicator
    And I am authenticated adminuser
    When I go to the edit indicator page for "Indicator one"
    And I follow "Delete"
    Then I should have zero indicators

  Scenario: Adminuser can deactivate and activate indicator
    Given I am authenticated adminuser
    And indicator
    When I go to the indicator page for "Indicator one"
    And I follow "Deactivate"
    Then I should be on the indicators page
    And I should see "deactivated"
    When I go to the indicator page for "Indicator one"
    And I follow "Activate"
    Then I should be on the indicators page
    And I should see "Indicator one"

  Scenario: User can view my indicators page
    Given I am authenticated user
    And indicator
    And indicator by admin
    When I go to the user indicators page for "pepe-moreno@sample.com"
    Then I should see "Indicator one"
    And I should not see "Indicator by admin"

  @javascript
  Scenario: User can remove action relation from indicator
    Given indicator with action relations
    And I am authenticated adminuser
    When I go to the indicator page for "Indicator one with relation"
    And I should see "First one"
    When I follow "Edit"
    And I click on overlapping ".remove_fields_preview"
    And I press "Update"
    Then I should be on the indicator page for "Indicator one with relation"
    When I go to the indicator page for "Indicator one with relation"
    Then I should not see "First one"

   @javascript
   Scenario: User can add action relation to indicator
     Given I am authenticated user
     And indicator
     And first act by admin
     And act_indicator_relation_types
     When I go to the edit indicator page for "Indicator one"
     And I click on overlapping ".add_action"
     And I select from the following hidden field ".relation_act_id" with "First act by admin" within ".indicator_act_indicator_relations_act_id"
     And I select from the following field ".relation_type_id" with "contains"
     When I fill in the following field ".relation_start_date" with "1990-03-10"
     When I fill in the following field ".relation_end_date" with "2010-03-10"
     And I press "Update"
     And I go to the indicator page for "Indicator one"
     Then I should see "First act by admin" within ".relationtitle"
     And I should see "Belongs To" within ".relationtype"

  @javascript
  Scenario: User can not add action relation to indicator if relation exists
    Given I am authenticated adminuser
    And action with indicator relations
    And act
    When I go to the edit indicator page for "Indicator one with relation"
    And I click on overlapping ".add_action"
    And I select from the following hidden field ".relation_act_id" with "Third one" within ".indicator_act_indicator_relations_act_id"
    Then I should not be able to select from the following field ".relation_act_id" with "Action with indicator"

  # For locations see location.feature
