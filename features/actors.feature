Feature: Actors
In order to manage actors
As an adminuser
I want to manage an actor

  Scenario: User can not view actors page and actor page without login
    Given user
    And person
    And organization by admin
    When I go to the actors page
    And I should see "You need to sign in or sign up before continuing."
    Then I should be on the login page

  Scenario: User can edit owned actor micro
    Given I am authenticated user
    And organization
    And department
    And person
    When I go to the edit actor page for "Person one"
    And I fill in "actor_micro_name" with "New Person"
    And I fill in "actor_micro_observation" with "It's description for person"
    And I select "Male" from "actor_micro_gender"
    And I select "Mr." from "actor_micro_title"
    When I fill in "actor_micro_date_of_birth" with "1990-12-17"
    And I press "Update"
    Then I should be on the edit micro member actor page for "New Person"
    And I should see "New Person"

  Scenario: User can edit owned actor meso
    Given I am authenticated user
    And organization
    And department
    When I go to the edit actor page for "Department one"
    And I fill in "actor_meso_name" with "New Department"
    And I fill in "actor_meso_observation" with "It's description for department"
    And I press "Update"
    Then I should be on the edit meso member actor page for "New Department"
    And I should see "New Department"

  Scenario: User can edit owned actor macro
    Given I am authenticated user
    And organization
    When I go to the edit actor page for "Organization one"
    And I fill in "actor_macro_name" with "New Organization"
    And I fill in "actor_macro_observation" with "It's description for organization"
    When I select "Global" from "actor_macro_operational_field"
    And I press "Update"
    Then I should be on the actor page for "New Organization"
    And I should see "New Organization"

  Scenario: User can change actor type from macro to meso
    Given I am authenticated user
    And organization
    When I go to the edit actor page for "Organization one"
    And I select "Meso" from "actor_macro_type"
    And I fill in "actor_macro_name" with "New Department"
    And I fill in "actor_macro_observation" with "It's description for department"
    And I press "Update"
    Then I should be on the edit meso member actor page for "New Department"
    And I should have one actor meso
    And I should see "New Department"

  Scenario: Adminuser can edit not owned actor
    Given user
    And person
    And I am authenticated adminuser
    When I go to the actor page for "Person one"
    Then I should be on the actor page for "Person one"

  Scenario: User can add macros and mesos to actor micro
    Given I am authenticated user
    And person
    And organization
    And department
    When I go to the edit actor page for "Person one"
    And I follow "Edit relation"
    And I follow "Add" within ".add_macro"
    When I go to the actor page for "Person one"
    Then I should see "Organization one"
    When I go to the edit actor page for "Person one"
    And I follow "Edit relation"
    And I follow "Add" within ".add_meso"
    When I go to the actor page for "Person one"
    Then I should see "Department one"
    When I go to the edit actor page for "Person one"
    And I follow "Edit relation"
    Then I should not see ".add_meso"
    When I follow "Remove" within ".remove_meso"
    And I go to the actor page for "Person one"
    Then I should not see "Department one"

  Scenario: User can add macros to meso actor
    Given I am authenticated user
    And organization
    And department
    When I go to the edit actor page for "Department one"
    And I follow "Edit relation"
    And I follow "Add" within ".add_macro"
    When I go to the actor page for "Department one"
    Then I should see "Organization one"
    When I go to the edit actor page for "Department one"
    And I follow "Edit relation"
    Then I should not see ".add_macro"
    When I follow "Remove" within ".remove_macro"
    Then I go to the actor page for "Department one"
    And I should not see "Organization one"

  Scenario: User can create actor
    Given user
    And person
    And I am authenticated adminuser
    When I go to the new actor page
    And I select "Macro" from "actor_type"
    And I fill in "actor_name" with "Orga by admin"
    And I press "Create"
    Then I should have one actor
    And I should be on the edit actor page for "Orga by admin"

  Scenario: User can not edit not owned actor
    Given I am authenticated user
    And organization by admin
    When I go to the edit actor page for "Organization by admin"
    Then I should be on the home page
    And I should see "You are not authorized to access this page."

  Scenario: Adminuser can remove not owned actor
    Given user
    And person
    And I am authenticated adminuser
    When I go to the edit actor page for "Person one"
    And I follow "Delete"
    Then I should have zero actors

  Scenario: Adminuser can deactivate and activate actor micro
    Given user
    And person
    And I am authenticated adminuser
    When I go to the actor page for "Person one"
    And I follow "Deactivate"
    Then I should be on the actors page
    And I should see "deactivated"
    When I go to the actors page with filter active
    Then I should not see "Person one"
    When I go to the actor page for "Person one"
    And I follow "Activate"
    Then I should be on the actors page
    And I should see "Person one"

  Scenario: Adminuser can deactivate and activate actor meso
    Given user
    And department
    And I am authenticated adminuser
    When I go to the actor page for "Department one"
    And I follow "Deactivate"
    Then I should be on the actors page
    And I should see "deactivated"
    When I go to the actors page with filter active
    Then I should not see "Department one"
    When I go to the actor page for "Department one"
    And I follow "Activate"
    Then I should be on the actors page
    And I should see "Department one"

  Scenario: Adminuser can deactivate and activate actor macro
    Given user
    And organization
    And I am authenticated adminuser
    When I go to the actor page for "Organization one"
    And I follow "Deactivate"
    Then I should be on the actors page
    And I should see "deactivated"
    When I go to the actors page with filter active
    Then I should not see "Organization one"
    When I go to the actor page for "Organization one"
    And I follow "Activate"
    Then I should be on the actors page
    And I should see "Organization one"

  Scenario: User can view my actors page
    Given I am authenticated user
    And person
    And department
    And organization
    And organization by admin
    When I go to the user actors page for "pepe-moreno@sample.com"
    Then I should see "Person one"
    And I should see "Department one"
    And I should see "Organization one"
    And I should not see "Organization by admin"

  Scenario: User can edit membership start and end dates
    Given I am authenticated user
    And person
    And department
    When I go to the edit actor page for "Person one"
    And I follow "Edit relation"
    And I follow "Add" within ".add_meso"
    And I follow "Edit" within ".edit_meso"
    When I fill in "actor_relation_start_date" with "1990-03-10"
    When I fill in "actor_relation_end_date" with "2010-03-10"
    And I press "Update"
    Then I should see "from: March 10, 1990 - to: March 10, 2010"

  Scenario: User can edit membership title and title reverse
    Given I am authenticated user
    And person
    And department
    And actors relation
    When I go to the edit actor page for "Person one"
    And I follow "Edit relation"
    And I follow "Add" within ".add_meso"
    And I follow "Edit" within ".edit_meso"
    When I select "actor - actor (link) (relational namespaces: partners with - partners with)" from "actor_relation_relation_type_id"
    Then I press "Update"
  
  @javascript
  Scenario: User can add location to actor
    Given I am authenticated user
    And person with relations
    When I go to the edit actor page for "Person one"
    And I click on ".add_fields"
    And I fill in the following field ".localization_name" with "Test location" within ".actor_micro_localizations_name"
    And I fill in the following field ".localization_lat" with "22.22222" within ".actor_micro_localizations_lat"
    And I fill in the following field ".localization_long" with "11.11111" within ".actor_micro_localizations_long"
    And I press "Update"
    Then I should be on the actor page for "Person one"
    And I should see "Test location"

  Scenario: User can remove location from actor
    Given I am authenticated adminuser
    And user organization with localization
    When I go to the edit actor page for "Organization by user"
    And I click on ".remove_fields"
    And I press "Update"
    Then I should be on the actor page for "Organization by user"
    And I should not see "Test location"
