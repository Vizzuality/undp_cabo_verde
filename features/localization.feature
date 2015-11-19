Feature: Localizations
In order to manage localizations
As a user
I want to manage a actor localization

  Scenario: User can edit localization on owned actor
    Given I am authenticated user
    And organization
    And organization_localization
    When I go to the actor page for "Organization one"
    And I follow "Edit localization"
    And I fill in "localization_name" with "New localization"
    And I press "Update"
    Then I should be on the edit actor page for "Organization one"
    When I go to the actor page for "Organization one"
    And I should see "New localization"

  Scenario: User can create localization for owned actor
    Given I am authenticated user
    And person
    When I go to the edit actor page for "Person one"
    And I follow "Add localization"
    And I fill in "localization_name" with "Person localization"
    And I fill in "localization_lat" with "4343244243432"
    And I fill in "localization_long" with "4543656677568768"
    And I press "Create"
    Then I should be on the edit actor page for "Person one"
    When I go to the actor page for "Person one"
    Then I should have a localization
    And I should see "Person localization"

  Scenario: Adminuser can not edit localization without latitude
    Given I am authenticated adminuser
    And user organization with localization
    When I go to the actor page for "Organization by user"
    And I follow "Edit localization"
    And I fill in "localization_lat" with ""
    And I press "Update"
    Then I should see "Please review the problems below:"
    And I should see "can't be blank"

  Scenario: Adminuser can deactivate and activate localization
    Given I am authenticated adminuser
    And user organization with localization
    When I go to the actor page for "Organization by user"
    And I follow "Deactivate" within ".deactivate_localization"
    And I go to the actor page for "Organization by user"
    Then I should see "Activate" within ".activate_localization"
    When I follow "Activate" within ".activate_localization"
    And I go to the actor page for "Organization by user"
    Then I should see "Deactivate" within ".deactivate_localization"
    