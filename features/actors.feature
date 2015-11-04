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
    And I should see "Organization by admin"
    When I follow "Organization by admin"
    Then I should be on the actor page for "Organization by admin"
    And I should see "Organization by admin (ActorMacro)"

  Scenario: User can edit owned actor micro
    Given I am authenticated user
    And organization
    And department
    And person
    When I go to the edit actor page for "Person one"
    And I fill in "actor_micro_name" with "New Person"
    And I fill in "actor_micro_observation" with "It's description for person"
    And I select "Male" from "actor_micro_gender"
    And I select "Mr" from "actor_micro_title"
    When I select datetime "1990 March 10" as the "actor_micro_date_of_birth"
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
    And I fill in "actor_macro_observation" with "It's description for department"
    When I select "International" from "actor_macro_operational_filed"
    And I press "Update"
    Then I should be on the actor page for "New Organization"
    And I should see "New Organization"

  Scenario: Adminuser can edit not owned actor
    Given user
    And person
    And I am authenticated adminuser
    When I go to the actor page for "Person one"
    Then I should have one actor

  Scenario: User can add macros and mesos to actor micro
    Given I am authenticated user
    And person
    And organization
    And department
    When I go to the edit actor page for "Person one"
    And I follow "Edit membership"
    And I follow "Add" within ".add_macro"
    When I go to the actor page for "Person one"
    Then I should see "Organization one"
    When I go to the edit actor page for "Person one"
    And I follow "Edit membership"    
    And I follow "Add" within ".add_meso"
    When I go to the actor page for "Person one"
    Then I should see "Department one"
    When I go to the edit actor page for "Person one"
    And I follow "Edit membership"    
    And I follow "Remove" within ".remove_meso"
    When I go to the actor page for "Person one"
    Then I should not see "Department one"

  Scenario: User can add macros to meso actor
    Given I am authenticated user
    And organization
    And department
    When I go to the edit actor page for "Department one"
    And I follow "Edit membership"
    And I follow "Add" within ".add_macro"
    When I go to the actor page for "Department one"
    Then I should see "Organization one"
    When I go to the edit actor page for "Department one"
    And I follow "Edit membership"    
    And I follow "Remove" within ".remove_macro"
    When I go to the actor page for "Department one"
    Then I should not see "Organization one"

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
