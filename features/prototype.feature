Feature: Prototype

  @javascript
  Scenario: User can see the actors and actions markers
    Given I am on the prototype page
    Then I should see all the actors markers
    And I should see all the actions markers

  @javascript
  Scenario: User can see the details of a marker with a popup
    Given I am authenticated user
    And I have an organization with location
    And I am on the prototype page
    And I wait for ajax
    Then I debug
    And I click on the actor's marker with id 1
