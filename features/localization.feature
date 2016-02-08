Feature: Localizations
In order to manage localizations
As a user
I want to manage a actor and act localization

  @javascript
  Scenario: User can add location to action
    Given I am authenticated user
    And person
    When I go to the edit actor page for "Person one"
    And I click on ".add_location"
    And I fill in the following field ".localization_name" with "Test location" within ".actor_micro_localizations_name"
    And I fill in the following field ".localization_lat" with "22.22222" within ".actor_micro_localizations_lat"
    And I fill in the following field ".localization_long" with "11.11111" within ".actor_micro_localizations_long"
    And I press "Update"
    Then I should be on the actor page for "Person one"
    And the disabled field "Lat" should contain "22.22222" within ".actor_micro_localizations_lat"

  @javascript
  Scenario: User can remove location from actor
    Given I am authenticated adminuser
    And user organization with localization
    When I go to the edit actor page for "Organization by user"
    And I click on ".remove_fields"
    And I press "Update"
    Then I should be on the actor page for "Organization by user"
    And I should not see "Test location"

  @javascript
  Scenario: User can add location to action
    Given I am authenticated adminuser
    And action with relations
    When I go to the edit act page for "Action one"
    And I click on ".add_location"
    And I fill in the following field ".localization_name" with "Test location" within ".act_micro_localizations_name"
    And I fill in the following field ".localization_lat" with "22.22222" within ".act_micro_localizations_lat"
    And I fill in the following field ".localization_long" with "11.11111" within ".act_micro_localizations_long"
    And I press "Update"
    Then I should be on the act page for "Action one"
    And the disabled field "Lat" should contain "22.22222" within ".act_micro_localizations_lat"

  @javascript
  Scenario: User can remove location from action
    Given I am authenticated adminuser
    And user act with localization
    When I go to the edit act page for "First act by user"
    And I click on ".remove_fields"
    And I press "Update"
    Then I should be on the act page for "First act by user"
    And I should not see "Test location"
