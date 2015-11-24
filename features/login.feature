Feature: Login
In order to login
As an user
I want to login, logout and reset password

  Scenario: User login
    Given I am registrated user
    And I am on the login page
    And I fill in "Email" with "test-user@sample.com"
    And I fill in "Password" with "password"
    And I press "Log in"
    Then I should see "Signed in successfully."
    And I should be on the dashboard page

  Scenario: User logout
    Given I am authenticated user
    And I am on the dashboard page
    When I follow "Logout"
    Then I should see "Signed out successfully."
    And I am on the home page

  Scenario: Password reset
    Given I am registrated user
    And I am on the login page
    Then I follow "Forgot your password?"
    And I fill in "Email" with "test-user@sample.com"
    And I press "Send me reset password instructions"
    Then I should see "You will receive an email with instructions on how to reset your password in a few minutes."
    And "test-user@sample.com" should receive an email
    When "test-user@sample.com" opens the email
    And I follow "Change my password" in the email
    When I fill in "New password" with "qwertyui"
    And I fill in "Confirm your new password" with "qwertyui"
    And I press "Change my password"
    Then I should see "Your password has been changed successfully."
    And I should be on the dashboard page
