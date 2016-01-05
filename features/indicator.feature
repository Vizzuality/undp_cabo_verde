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
    And the field "Name" should contain "New Indicator"
    And the field "Alternative name" should contain "It's name for indicator"
    And the field "Description" should contain "It's description for indicator"

  Scenario: Adminuser can edit not owned indicator
    Given user
    And indicator
    And I am authenticated adminuser
    When I go to the edit indicator page for "Indicator one"
    Then I should be on the edit indicator page for "Indicator one"
    When I fill in "indicator_name" with "New Indicator"
    And I press "Update"
    Then I should be on the indicator page for "New Indicator"
    And the field "Name" should contain "New Indicator"

  Scenario: User can create indicator
    Given I am authenticated adminuser
    When I go to the new indicator page
    And I fill in "indicator_name" with "New Indicator"
    And I fill in "indicator_description" with "It's description for indicator"
    And I fill in "indicator_alternative_name" with "It's name for indicator"
    And I press "Create"
    Then I should be on the indicators page
    And I should see "New Indicator"

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

  # For locations see location.feature
