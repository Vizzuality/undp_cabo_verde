Feature: Login
In order to login
As an user
I want to login

  Scenario: User login
    Given I am registrated user
    And I am on the login page
    And I fill in "Email" with "test-user@sample.com"
    And I fill in "Password" with "password"
    And I press "Log in"
    Then I should see "Signed in successfully."
    And I should be on the home page