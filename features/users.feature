Feature: Users
In order to manage users
As an adminuser
I want to edit, view, activate, deactivate and make a user admin

  Scenario: User can view users page and user page
    Given I am authenticated user
    And adminuser
    When I go to the users page
    And I should see "Pepe"
    And I should see "Juanito"
    When I follow "Juanito Lolito"
    Then I should be on the user page for "admin@sample.com"
    And I should see "Juanito Lolito (admin)"

  Scenario: Adminuser can edit user
    Given user
    And I am authenticated adminuser
    When I go to the edit user page for "pepe-moreno@sample.com"
    And I fill in "user_firstname" with "Don"
    And I fill in "user_lastname" with "Morenito"
    And I fill in "user_institution" with "Radio 3"
    And I fill in "user_email" with "don-morenito@sample.com"
    And I press "Update"
    And the disabled field "Email" should contain "don-morenito@sample.com" within ".form-actions"
    And the disabled field "Institution" should contain "Radio 3" within ".form-actions"

  Scenario: Adminuser can make user admin
    Given user
    And I am authenticated adminuser
    When I go to the user page for "pepe-moreno@sample.com"
    And I follow "Make admin"
    Then I should have two adminusers

  Scenario: Adminuser can remove admin rights from user
    Given user
    And I am authenticated adminuser
    When I go to the user page for "pepe-moreno@sample.com"
    And I follow "Make admin"
    Then I should have two adminusers
    When I go to the edit user page for "pepe-moreno@sample.com"
    And I follow "Make user"
    Then I should be on the users page
    And I should have one adminuser

  Scenario: Adminuser can deactivate and activate user
    Given user
    And I am authenticated adminuser
    When I go to the user page for "pepe-moreno@sample.com"
    And I follow "Deactivate"
    Then I should be on the users page
    And I should see "deactivated"
    When I go to the users page with filter active
    Then I should not see "(deactivated)"
    When I go to the user page for "pepe-moreno@sample.com"
    And I follow "Activate"
    Then I should be on the users page
    And I should not see "(deactivated)"
