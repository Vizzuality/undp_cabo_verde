Feature: Actors
In order to manage actors
As an adminuser
I want to manage a actor

  Scenario: User can view actors page and actor page
    Given user
    And person
    And organization by admin
    When I go to the actors page
    And I should see "Person one"
    And I should see "Organization one"
    When I follow "Organization one"
    Then I should be on the actor page for "Organization one"
    And I should see "Organization one (ActorMacro)"

  Scenario: User can edit owned actor micro
    Given I am authenticated user
    And organization
    And department
    And person
    When I go to the edit actor page for "Person one"
    And I fill in "actor_micro_name" with "New Person"
    And I fill in "actor_micro_observation" with "It's description for person"
    And I select "Organization one" from "actor_micro_macro_ids"
    And I select "Department one" from "actor_micro_meso_ids"
    And I select "Male" from "actor_micro_gender"
    And I select "Mr" from "actor_micro_title"
    When I select datetime "1990 March 10" as the "actor_micro_date_of_birth"
    And I press "Update"
    Then I should be on the actors page
    And I should see "New Person (activated)"
    And I should have one micro_macro
    And I should have one micro_meso

  Scenario: User can edit owned actor meso
    Given I am authenticated user
    And organization
    And department
    When I go to the edit actor page for "Department one"
    And I fill in "actor_meso_name" with "New Department"
    And I fill in "actor_meso_observation" with "It's description for department"
    And I select "Organization one" from "actor_meso_macro_ids"
    And I press "Update"
    Then I should be on the actors page
    And I should see "New Department (activated)"
    And I should have one meso_macro

  Scenario: User can edit owned actor macro
    Given I am authenticated user
    And organization
    When I go to the edit actor page for "Organization one"
    And I fill in "actor_macro_name" with "New Organization"
    And I fill in "actor_macro_observation" with "It's description for department"
    When I select "International" from "actor_macro_operational_filed"
    And I press "Update"
    Then I should be on the actors page
    And I should see "New Organization (activated)"

  Scenario: Adminuser can edit not owned actor
    Given user
    And person
    And I am authenticated adminuser
    When I go to the actor page for "Person one"
    Then I should have one actor

  Scenario: User can create actor
    Given user
    And person
    And I am authenticated adminuser
    When I go to the new actor page
    And I select "ActorMacro" from "actor_type"
    And I fill in "actor_name" with "Orga by admin"
    And I press "Create"
    Then I should have one actor
    And I should be on the actor page for "Orga by admin"

  Scenario: User can not edit not owned actor
    Given I am authenticated user
    And organization by admin
    When I go to the edit actor page for "Organization one"
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
