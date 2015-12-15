Feature: Registration
In order to create account
As an user
I want to register

  Scenario: User registration
    Given I am on the register page
    When I fill in "Email" with "user1@sample.com"
    And I fill in "* Password" with "qwertyui"
    And I fill in "* Password confirmation" with "qwertyui"
    And I fill in "Firstname" with "Pepe"
    And I fill in "Institution" with "Columpio"
    And I press "Sign up"
    Then I should be on the root page
    And I should see "Welcome! You have signed up successfully."
    And I should see "Welcome to UNDP – Climate Action Intelligence Tool"
    And I should have an user
