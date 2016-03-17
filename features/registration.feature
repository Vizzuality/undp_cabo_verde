Feature: Registration
In order to create account
As an user
I want to register

  Scenario: User registration
    Given I am on the register page
    When I fill in "Email" with "user1@sample.com"
    And I fill in "* Password" with "qwertyui"
    And I fill in "* Confirm password" with "qwertyui"
    And I fill in "First name" with "Pepe"
    And I fill in "Institution" with "Columpio"
    And I press "Register"
    Then I should be on the root page
    And I should see "Welcome! You have signed up successfully."
    And I should see "Welcome to UNDP – Action Intelligence Tool"
    And I should have an user
