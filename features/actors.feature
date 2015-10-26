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
    And I should see "Organization one (Organization)"

  Scenario: User can edit owned actor
    Given I am authenticated user
    And person
    When I go to the edit actor page for "Person one"
    And I fill in "person_title" with "New Person"
    And I fill in "person_description" with "It's description for person"
    And I press "Update"
    Then I should be on the actors page
    And I should see "New Person (activated)"

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
    And I select "Organization" from "actor_type"
    And I fill in "actor_title" with "Orga by admin"
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

  Scenario: Adminuser can deactivate and activate actor
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
