Feature: Acts
In order to manage acts
As an adminuser
I want to manage an act

  Scenario: User can not view acts page and act page without login
    Given user
    And third act
    And first act by admin
    When I go to the acts page
    Then I should see "You need to sign in or sign up before continuing."
    And I should be on the login page

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
    Then I should be on the act page for "New Third"
    And the field "Name" should contain "New Third"

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
    Then I should be on the act page for "New Second"
    And the field "Name" should contain "New Second"
  
  @javascript
  Scenario: User can edit owned act macro and add custom domain
    Given I am authenticated user
    And first act
    And I should have one domain
    When I go to the edit act page for "First one"
    And I fill in "act_macro_name" with "New First"
    And I choose "act_macro_event_true"
    And I click on overlapping ".add_other_domain"
    And I fill in the following field ".name" with "Custom domain" within ".form-inputs-other-domains"
    And I press "Update"
    Then I should be on the act page for "New First"
    And the field "Name" should contain "New First"
    And I should have two domains

  Scenario: Adminuser can edit not owned act
    Given user
    And third act
    And I am authenticated adminuser
    When I go to the edit act page for "Third one"
    Then I should be on the edit act page for "Third one"

  Scenario: User can create act
    Given user
    And third act
    And I am authenticated adminuser
    When I go to the new act page
    And I select "Macro" from "act_type"
    And I fill in "act_name" with "Act by admin"
    And I check "Faith" within ".act_merged_domain_ids"
    And I press "Create"
    Then I should have one act
    And I should be on the act page for "Act by admin"

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

  # for locations see location.feature

  @javascript
  Scenario: User can add action relation to action
    Given I am authenticated user
    And act
    And second act
    And act_relation_types
    When I go to the edit act page for "Third one"
    And I click on ".add_child_action" within ".add-relations"
    Then I should see "Third one" within ".current-action-wrapper"
    When I select from the following field ".relation_child_id" with "Second one"
    And I select from the following field ".relation_type_id" with "belongs to"
    And I fill in the following field ".relation_start_date" with "1990-03-10"
    And I fill in the following field ".relation_end_date" with "2010-03-10"
    And I press "Update"
    And I go to the act page for "Third one"
    Then the select field "Action" should contain "Second one"
    And the select field "Relation title" should contain "belongs to"
    And the field "Start date" should contain "1990-03-10" within ".form-inputs-child"
    And the field "End date" should contain "2010-03-10" within ".form-inputs-child"

  @javascript
  Scenario: User can add action parent relation to action
    Given I am authenticated user
    And act
    And second act
    And act_relation_types
    When I go to the edit act page for "Third one"
    And I click on ".add_child_action" within ".add-relations"
    Then I should see "Third one" within ".current-action-wrapper"
    When I click on ".switch_parent_form"
    And I select from the following field ".relation_parent_id" with "Second one"
    And I select from the following field ".relation_type_id" with "belongs to"
    When I fill in the following field ".relation_start_date" with "1990-03-10"
    When I fill in the following field ".relation_end_date" with "2010-03-10"
    And I press "Update"
    Then I should be on the act page for "Third one"
    And the select field "Action" should contain "Second one" within ".form-inputs-parent"
    And the select field "Relation title" should contain "belongs to" within ".form-inputs-parent"
    And the field "Start date" should contain "1990-03-10" within ".form-inputs-parent"
    And the field "End date" should contain "2010-03-10" within ".form-inputs-parent"

  @javascript
  Scenario: User can remove action relation from action
    Given action with relations
    And I am authenticated adminuser
    When I go to the act page for "Action one"
    And the select field "Action" should contain "Second one"
    When I follow "Edit"
    And I click on ".remove_fields"
    And I press "Update"
    And I go to the act page for "Action one"
    Then I should not see "Department one"

  @javascript
  Scenario: User can add actor relation to action
    Given I am authenticated user
    And person
    And first act
    And act_actor_relation_types
    When I go to the edit act page for "First one"
    And I click on ".add_actor"
    And I select from the following field ".relation_actor_id" with "Person one"
    And I select from the following field ".relation_type_id" with "implements"
    When I fill in the following field ".relation_start_date" with "1990-03-10"
    When I fill in the following field ".relation_end_date" with "2010-03-10"
    And I press "Update"
    And I go to the act page for "First one"
    Then the select field "Actor" should contain "Person one"
    Then the select field "Current action" should contain "implements"
    And the field "Start date" should contain "1990-03-10" within ".form-inputs-actor"
    And the field "End date" should contain "2010-03-10" within ".form-inputs-actor"

  @javascript
  Scenario: User can remove actor relation from action
    Given action with actor relations
    And I am authenticated adminuser
    When I go to the act page for "Action one with relation"
    Then the select field "Actor" should contain "Person one"
    When I follow "Edit"
    And I click on ".remove_fields"
    And I press "Update"
    And I go to the act page for "Action one with relation"
    Then I should not see "First one"

  @javascript
  Scenario: User can add indicator relation to action
    Given I am authenticated user
    And first act
    And indicator
    And unit
    And act_indicator_relation_types
    When I go to the edit act page for "First one"
    And I click on ".add_indicator"
    And I select from the following field ".relation_indicator_id" with "Indicator one"
    And I select from the following field ".relation_type_id" with "contains"
    When I fill in the following field ".relation_start_date" with "1990-03-10"
    And I fill in the following field ".relation_end_date" with "2010-03-10"
    And I fill in the following field ".relation_deadline" with "2015-03-10"
    And I select from the following field ".relation_unit" with "Euro"
    And I fill in the following field ".relation_target_value" with "100.01"
    And I press "Update"
    And I go to the act page for "First one"
    Then the select field "Indicator" should contain "Indicator one"
    Then the select field "Current action" should contain "contains"
    And the field "Start date" should contain "1990-03-10" within ".form-inputs-indicator"
    And the field "End date" should contain "2010-03-10" within ".form-inputs-indicator"
    And the field "Deadline" should contain "2015-03-10" within ".form-inputs-indicator"
    And the select field "Unit" should contain "Euro" within ".form-inputs-indicator"
    And the field "Target value" should contain "100.01" within ".form-inputs-indicator"

  @javascript
  Scenario: User can remove indicator relation from action
    Given action with indicator relations
    And I am authenticated adminuser
    When I go to the act page for "Action with indicator"
    Then the select field "Indicator" should contain "Indicator one"
    When I follow "Edit"
    And I click on ".remove_indicator"
    And I press "Update"
    And I go to the act page for "Action with indicator"
    Then I should not have indicators

  @javascript
  Scenario: User can add measurement for indicator relation on action
    Given action with indicator relations
    And unit
    And I am authenticated adminuser
    When I go to the edit act page for "Action with indicator"
    And I click on ".add_measurement"
    And I fill in the following field ".measurement_date" with "2015-03-10"
    And I fill in the following field ".measurement_value" with "200"
    And I fill in the following field ".measurement_details" with "Measurement for indicator"
    And I select from the following field ".measurement_unit" with "Euro"
    And I press "Update"
    Then I should be on the act page for "Action with indicator"

  @javascript
  Scenario: User can remove indicator relation from action
    Given action with indicator relations and measurement
    And I am authenticated adminuser
    When I go to the act page for "Action with indicator and measurement"
    Then the select field "Indicator" should contain "Indicator one"
    When I follow "Edit"
    And I click on ".remove_measurement"
    And I press "Update"
    Then I should be on the act page for "Action with indicator and measurement"
