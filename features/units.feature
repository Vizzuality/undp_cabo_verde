Feature: Units
In order to manage localizations
As a user and admin user
I want to manage units

  Scenario: User can edit unit
    Given unit by authenticated user
    When I go to the units page
    Then I should see "Euro" within "#units"
    When I go to the edit unit page for "Euro"
    And I fill in the following field ".unit_name input" with "Dolar"
    And I fill in the following field ".unit_symbol input" with "$"
    And I press "Update"
    Then I should be on the units page
    Then I should see "Dolar"
    And I should see "$"
  
  @javascript
  Scenario: User can remove unit
    Given unit by authenticated user
    When I go to the units page
    And I follow "Delete"
    Then I should be on the units page
    And I should not see "Euro"
    And I should not have units

  Scenario: User can edit not owned unit
    Given I am authenticated user
    And unit by admin user
    When I go to the units page
    Then I should see "Euro"
    And I should see "Delete"

  @javascript
  Scenario: Admin User can remove user unit
    Given unit by user
    And I am authenticated adminuser
    When I go to the units page
    And I follow "Delete"
    Then I should be on the units page
    And I should not see "Euro"
    And I should not have units

  Scenario: Admin User can edit user unit
    Given unit by user
    And I am authenticated adminuser
    When I go to the units page
    Then I should see "Euro" within "#units"
    When I go to the edit unit page for "Euro"
    And I fill in the following field ".unit_name input" with "Dolar"
    And I fill in the following field ".unit_symbol input" with "$"
    And I press "Update"
    Then I should be on the units page
    Then I should see "Dolar"
    And I should see "$"
