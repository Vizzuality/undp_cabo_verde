Feature: Acts
In order to manage acts
As an adminuser
I want to manage an act

  Scenario: User can view acts page and act page
    Given user
    And third act
    And first act by admin
    When I go to the acts page
    And I should see "Third one"
    And I should see "First act by admin"
    When I follow "First act by admin"
    Then I should be on the act page for "First act by admin"
    And I should see "First act by admin (Macro)"

  Scenario: User can edit owned act micro
    Given I am authenticated user
    And first act
    And second act
    And third act
    When I go to the edit act page for "Third one"
    And I fill in "act_micro_name" with "New Third"
    When I fill in "act_micro_start_date" with "1990-03-10"
    When I fill in "act_micro_end_date" with "2010-03-10"
    And I press "Update"
    Then I should be on the edit micro member act page for "New Third"
    And I should see "New Third"

  Scenario: User can edit owned act meso
    Given I am authenticated user
    And first act
    And second act
    When I go to the edit act page for "Second one"
    And I fill in "act_meso_name" with "New Second"
    And I choose "act_meso_human_true"
    And I fill in "act_meso_alternative_name" with "New alternative Second"
    And I fill in "act_meso_short_name" with "New short Second"
    And I fill in "act_meso_description" with "Lorem ipsum..."
    And I press "Update"
    Then I should be on the edit meso member act page for "New Second"
    And I should see "New Second"

  Scenario: User can edit owned act macro
    Given I am authenticated user
    And first act
    When I go to the edit act page for "First one"
    And I fill in "act_macro_name" with "New First"
    And I choose "act_macro_event_true"
    And I press "Update"
    Then I should be on the act page for "New First"
    And I should see "New First"

  Scenario: Adminuser can edit not owned act
    Given user
    And third act
    And I am authenticated adminuser
    When I go to the edit act page for "Third one"
    Then I should be on the edit act page for "Third one"

  Scenario: User can add macros and mesos to act micro
    Given I am authenticated user
    And third act
    And first act
    And second act
    When I go to the edit act page for "Third one"
    And I follow "Edit relation"
    And I follow "Add" within ".add_macro"
    When I go to the act page for "Third one"
    Then I should see "First one"
    When I go to the edit act page for "Third one"
    And I follow "Edit relation"
    And I follow "Add" within ".add_meso"
    When I go to the act page for "Third one"
    Then I should see "Second one"
    When I go to the edit act page for "Third one"
    And I follow "Edit relation"
    Then I should not see ".add_meso"
    When I follow "Remove" within ".remove_meso"
    And I go to the act page for "Third one"
    Then I should not see "Second one"

  Scenario: User can add macros to meso act
    Given I am authenticated user
    And first act
    And second act
    When I go to the edit act page for "Second one"
    And I follow "Edit relation"
    And I follow "Add" within ".add_macro"
    When I go to the act page for "Second one"
    Then I should see "First one"
    When I go to the edit act page for "Second one"
    And I follow "Edit relation"
    Then I should not see ".add_macro"
    When I follow "Remove" within ".remove_macro"
    Then I go to the act page for "Second one"
    And I should not see "First one"

  Scenario: User can create act
    Given user
    And third act
    And I am authenticated adminuser
    When I go to the new act page
    And I select "Macro" from "act_type"
    And I fill in "act_name" with "Act by admin"
    And I press "Create"
    Then I should have one act
    And I should be on the edit act page for "Act by admin"

  Scenario: User can not edit not owned act
    Given I am authenticated user
    And first act by admin
    When I go to the edit act page for "First act by admin"
    Then I should be on the home page
    And I should see "You are not authorized to access this page."

  Scenario: Adminuser can remove not owned act
    Given user
    And third act
    And I am authenticated adminuser
    When I go to the edit act page for "Third one"
    And I follow "Delete"
    Then I should have zero acts

  Scenario: Adminuser can deactivate and activate act micro
    Given user
    And third act
    And I am authenticated adminuser
    When I go to the edit act page for "Third one"
    And I follow "Deactivate"
    Then I should be on the acts page
    And I should see "deactivated"
    When I go to the acts page with filter active
    Then I should not see "Third one"
    When I go to the edit act page for "Third one"
    And I follow "Activate"
    Then I should be on the acts page
    And I should see "Third one"

  Scenario: Adminuser can deactivate and activate act meso
    Given user
    And second act
    And I am authenticated adminuser
    When I go to the act page for "Second one"
    And I follow "Deactivate"
    Then I should be on the acts page
    And I should see "deactivated"
    When I go to the acts page with filter active
    Then I should not see "Second one"
    When I go to the act page for "Second one"
    And I follow "Activate"
    Then I should be on the acts page
    And I should see "Second one"

  Scenario: Adminuser can deactivate and activate act macro
    Given user
    And first act
    And I am authenticated adminuser
    When I go to the act page for "First one"
    And I follow "Deactivate"
    Then I should be on the acts page
    And I should see "deactivated"
    When I go to the acts page with filter active
    Then I should not see "First one"
    When I go to the act page for "First one"
    And I follow "Activate"
    Then I should be on the acts page
    And I should see "First one"

  Scenario: User can view my acts page
    Given I am authenticated user
    And third act
    And second act
    And first act
    And first act by admin
    When I go to the user acts page for "pepe-moreno@sample.com"
    Then I should see "Third one"
    And I should see "Second one"
    And I should see "First one"
    And I should not see "First act by admin"

  Scenario: User can edit membership start and end dates
    Given I am authenticated user
    And third act
    And second act
    When I go to the edit act page for "Third one"
    And I follow "Edit relation"
    And I follow "Add" within ".add_meso"
    And I follow "Edit" within ".edit_meso"
    When I select datetime "1990 March 10" as the "act_relation_start_date"
    And I select datetime "2010 March 10" as the "act_relation_end_date"
    And I press "Update"
    Then I should see "from: March 10, 1990 - to: March 10, 2010"

  Scenario: User can edit membership title and title reverse
    Given I am authenticated user
    And third act
    And second act
    And acts relation
    When I go to the edit act page for "Third one"
    And I follow "Edit relation"
    And I follow "Add" within ".add_meso"
    And I follow "Edit" within ".edit_meso"
    When I select "action - action (relational namespaces: belongs to - contains)" from "act_relation_relation_type_id"
    Then I press "Update"

  @javascript
  Scenario: User can add location to action
    Given I am authenticated user
    And action with relations
    When I go to the edit act page for "Action one"
    And I click on ".add_location"
    And I fill in the following field ".localization_name" with "Test location" within ".act_micro_localizations_name"
    And I fill in the following field ".localization_lat" with "22.22222" within ".act_micro_localizations_lat"
    And I fill in the following field ".localization_long" with "11.11111" within ".act_micro_localizations_long"
    And I press "Update"
    Then I should be on the act page for "Action one"
    And I should see "Test location"

  Scenario: User can remove location from action
    Given I am authenticated adminuser
    And user act with localization
    When I go to the edit act page for "First act by user"
    And I click on ".remove_fields"
    And I press "Update"
    Then I should be on the act page for "First act by user"
    And I should not see "Test location"
