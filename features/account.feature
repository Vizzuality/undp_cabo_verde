Feature: Account
In order to edit account info
As an user
I want to edit account

  Scenario: User can edit account data
    Given I am authenticated user
    And I am on the home page
    When I go to the profile edit page for "test-user@sample.com"
    And I should see "Edit User"
    When I fill in "user_email" with "test@test.com"
    And I fill in "Firstname" with "Don"
    And I fill in "Lastname" with "Pepito"
    And I fill in "user_current_password" with "password"
    And I press "Update"
    Then I should see "Your account has been updated successfully."
    And I should see "Hello Don Pepito"

  Scenario: User account delete
    Given I am authenticated user
    And I am on the home page
    When I go to the profile edit page for "test_user@sample.com"
    And I should see "Edit User"
    When I follow "Cancel my account"
    Then I should be on the home page
    And I should see "Bye! Your account has been successfully cancelled. We hope to see you again soon."