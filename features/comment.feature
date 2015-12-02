Feature: Comments
In order to manage comments
As an adminuser
I want to create activate and deactivate a comment

  Scenario: User can create comment on act
    Given I am authenticated user
    And third act
    When I go to the act page for "Third one"
    Then I should see "Third one (Micro)"
    When I fill in "comment_body" with "Lorem ipsum..."
    And I press "Create comment"
    Then I should be on the act page for "Third one"
    And I should see "Lorem ipsum..."

  Scenario: User can create comment on not owned act
    Given first act by admin
    And I am authenticated user
    When I go to the act page for "First act by admin"
    When I fill in "comment_body" with "Lorem ipsum..."
    And I press "Create comment"
    Then I should be on the act page for "First act by admin"
    And I should see "Lorem ipsum..."

  Scenario: User can not activate deactivate not owned comment
    Given first act by admin with comment
    And I am authenticated user
    When I go to the act page for "Comment on first act by admin"
    Then I should see "Comment on first act by admin"
    And I should not see "Deactivate" within "#comments"

  Scenario: User can activate deactivate owned comment
    Given I am authenticated user
    And first act by auth user with comment
    When I go to the act page for "Comment on first act by user"
    And I follow "Deactivate" within "#comments"
    And I should see "Activate" within "#comments"
    When I follow "Activate" within "#comments"
    And I should see "Deactivate" within "#comments"

  Scenario: AdminUser can activate deactivate not owned comment
    Given first act by user with comment
    And I am authenticated adminuser
    When I go to the act page for "Comment on first act by user"
    And I follow "Deactivate" within "#comments"
    And I should see "Activate" within "#comments"
    When I follow "Activate" within "#comments"
    And I should see "Deactivate" within "#comments"