Feature: Actors
In order to manage actors
As an adminuser
I want to manage an actor

  Scenario: User can not view actors page and actor page without login
    Given user
    And person
    And organization by admin
    When I go to the actors page
    Then I should see "You need to sign in or sign up before continuing."
    And I should be on the login page

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
    And I press "Update"
    Then I should be on the actor page for "New Person"
    And the field "Name" should contain "New Person"

  Scenario: User can edit owned actor meso
    Given I am authenticated user
    And organization
    And department
    When I go to the edit actor page for "Department one"
    And I fill in "actor_meso_name" with "New Department"
    And I fill in "actor_meso_observation" with "It's description for department"
    And I press "Update"
    Then I should be on the actor page for "New Department"
    And the field "Name" should contain "New Department"

  Scenario: User can edit owned actor macro
    Given I am authenticated user
    And organization
    When I go to the edit actor page for "Organization one"
    And I fill in "actor_macro_name" with "New Organization"
    And I fill in "actor_macro_observation" with "It's description for organization"
    When I select "Global" from "actor_macro_operational_field"
    And I press "Update"
    Then I should be on the actor page for "New Organization"
    And the field "Name" should contain "New Organization"

  # The field level is disabled on edit form!
  # Scenario: User can change actor type from macro to meso
  #   Given I am authenticated user
  #   And organization
  #   When I go to the edit actor page for "Organization one"
  #   And I select "Meso" from "actor_macro_type"
  #   And I fill in "actor_macro_name" with "New Department"
  #   And I fill in "actor_macro_observation" with "It's description for department"
  #   And I press "Update"
  #   Then I should be on the actor page for "New Department"
  #   And I should have one actor meso
  #   And the field "Name" should contain "New Department"

  Scenario: Adminuser can edit not owned actor
    Given user
    And person
    And I am authenticated adminuser
    When I go to the actor page for "Person one"
    Then I should be on the actor page for "Person one"

  Scenario: User can create actor
    Given user
    And socio_cultural_domain_2
    And operational field
    And I am authenticated adminuser
    When I go to the new actor page
    And I select "Macro" from "actor_type"
    And I fill in "actor_name" with "Orga by admin"
    And I check "Faith" within ".actor_socio_cultural_domain_ids"
    And I select "International" from "actor_operational_field"
    And I press "Create"
    Then I should have one actor
    And I should be on the actor page for "Orga by admin"

  @javascript
  Scenario: User can edit actor with custom domain
    Given user
    And socio_cultural_domain_tree
    And organization
    And operational field
    And I am authenticated adminuser
    And I should have five domains
    When I go to the edit actor page for "Organization one"
    And I click on overlapping ".add_other_domain"
    And I fill in the following field ".name" with "Custom domain" within ".form-inputs-other-domains"
    And I press "Update"
    Then I should be on the actor page for "Organization one"
    And I should have one actor
    And I should have six domains

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

  # For locations see location.feature
  @javascript
  Scenario: User can add actor child relation to actor
    Given I am authenticated user
    And person
    And organization
    And department
    And relation_types
    When I go to the edit actor page for "Person one"
    And I click on overlapping ".add_child_actor" within "#actor_relation_form"
    Then I should see "Person one" within ".current-actor-wrapper"
    And I select from the following field ".relation_child_id" with "Organization one"
    And I select from the following field ".relation_type_id" with "contains"
    When I fill in the following field ".relation_start_date" with "1990-03-10"
    When I fill in the following field ".relation_end_date" with "2010-03-10"
    And I press "Update"
    And I go to the actor page for "Person one"
    Then I should see "Belongs To" within "#actor_relation_form"
    And I should see "Organization one" within "#actor_relation_form"

  @javascript
  Scenario: User can add actor parent relation to actor
    Given I am authenticated user
    And person
    And organization
    And department
    And relation_types
    When I go to the edit actor page for "Person one"
    And I click on overlapping ".add_child_actor" within "#actor_relation_form"
    Then I should see "Person one" within ".current-actor-wrapper"
    When I click on overlapping ".switch_parent_form"
    And I select from the following field ".relation_parent_id" with "Organization one"
    And I select from the following field ".relation_type_id" with "contains"
    When I fill in the following field ".relation_start_date" with "1990-03-10"
    When I fill in the following field ".relation_end_date" with "2010-03-10"
    And I press "Update"
    And I go to the actor page for "Person one"
    Then I should see "Organization one"
    And I should see "Contains"

  @javascript
  Scenario: User can not add actor parent relation to actor if relation exists
    Given I am authenticated adminuser
    And actor with relations
    And person
    When I go to the edit actor page for "Person one with relation"
    And I click on overlapping ".add_child_actor" within "#actor_relation_form"
    Then I should see "Person one" within ".current-actor-wrapper"
    When I click on overlapping ".switch_parent_form"
    And I select from the following field ".relation_parent_id" with "Person one"
    Then I should not be able to select from the following field ".relation_parent_id" with "Department one"

  @javascript
  Scenario: User can remove actor relation from actor
    Given actor with relations
    And I am authenticated adminuser
    When I go to the actor page for "Person one with relation"
    And I should see "Department one"
    When I follow "Edit"
    And I click on overlapping ".remove_fields_preview"
    And I press "Update"
    And I go to the actor page for "Person one with relation"
    Then I should not see "Department one"

   @javascript
   Scenario: User can add action relation to actor
     Given I am authenticated user
     And person
     And first act
     And act_actor_relation_types
     When I go to the edit actor page for "Person one"
     And I click on overlapping ".action_relations"
     Then I click on hidden ".add_action" on "#action_relation_form" within ".tabs-content"
     And I select from the following field ".relation_action_id" with "First one"
     And I select from the following field ".relation_type_id" with "implements"
     When I fill in the following field ".relation_start_date" with "1990-03-10"
     When I fill in the following field ".relation_end_date" with "2010-03-10"
     And I press "Update"
     And I go to the actor page for "Person one"
     And I click on overlapping ".action_relations"
     Then I should see tab "#action_relation_form" within ".tabs-content"
     Then I should see "First one" within ".relationtitle"
     And I should see "Implements" within ".relationtype"

  @javascript
  Scenario: User can not add action relation to actor if relation exists
    Given I am authenticated adminuser
    And actor with action relations
    And act
    When I go to the edit actor page for "Person one with relation"
    And I click on overlapping ".action_relations"
    Then I click on hidden ".add_action" on "#action_relation_form" within ".tabs-content"
    Then I should see "Person one with relation" within ".current-actor-wrapper"
    And I select from the following field ".relation_action_id" with "Third one"
    Then I should not be able to select from the following field ".relation_action_id" with "First one"

   @javascript
   Scenario: User can remove action relation from actor
     Given actor with action relations
     And I am authenticated adminuser
     When I go to the actor page for "Person one with relation"
     Then I should see "GENERAL INFO"
     And I click on overlapping ".action_relations"
     Then I should see tab "#action_relation_form" within ".tabs-content"
     Then I should see "First one" within ".relationtitle"
     When I follow "Edit"
     And I click on overlapping ".action_relations"
     Then I click on hidden ".remove_fields" on "#action_relation_form" within ".tabs-content"
     And I press "Update"
     And I go to the actor page for "Person one with relation"
     And I click on overlapping ".action_relations"
     Then I should see tab "#action_relation_form" within ".tabs-content"
     Then I should not see "First one"
