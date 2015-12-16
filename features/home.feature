Feature: Home page
In order to view homepage
As an user
I want to follow links

  Scenario: User will be redirect to login page and back to new actor page after following create actor on homepage
    Given I am registrated user
    And I am on the home page
    Then I should see "Choose what you want to add"
    When I follow "Actors" within ".options-box-second"
    Then I should be on the login page
    And I fill in "Email" with "test-user@sample.com"
    And I fill in "Password" with "password"
    And I press "Log in"
    Then I should see "Signed in successfully."
    And I should be on the new actor page
