Feature: Callouts

  Background:

  Scenario: Modal ordering
    Given I am on "http://learn.code.org/s/1/level/2?noautoplay=true"
    And I rotate to landscape
    And callout "0" is visible
    And ".modal-backdrop" should be in front of "#qtip-0"
    And I press "x-close"

  Scenario: Closing using "x" button
    Given I am on "http://learn.code.org/s/1/level/2?noautoplay=true"
    And I rotate to landscape
    And I press "x-close"
    And there's an image "assets/x_button.png"
    And callout "0" is visible
    And callout "1" is visible
    And I close callout "1"
    And callout "0" is visible
    And callout "1" is hidden
    And I close callout "0"
    And callout "0" is hidden

  Scenario Outline: Callouts having correct content and being dismissable
    Given I am on "<url>"
    And I rotate to landscape
    And I press "x-close"
    And callout "<callout_id>" is visible
    And callout "<callout_id>" has text: <text>
    And I click selector "<close_target>"
    And callout "<callout_id>" is hidden
  Examples:
    | url                                                | callout_id | text                                                                             | close_target           |
    | http://learn.code.org/s/1/level/2?noautoplay=true  | 1          | Hit "Run" to try your program                                                    | #runButton             |
    | http://learn.code.org/s/1/level/7?noautoplay=true  | 0          | Click here to watch the video again                                              | #thumbnail_mgooqyWMTxk |
    | http://learn.code.org/s/1/level/10?noautoplay=true | 0          | Blocks that are grey can't be moved or deleted. Can you solve the puzzle anyway? | g                      |
    | http://learn.code.org/s/1/level/12?noautoplay=true | 0          | Click here to see the code for the program you're making                         | #show-code-header      |
    | http://learn.code.org/s/1/level/16?noautoplay=true | 0          | The instructions for each puzzle are repeated here                               | #prompt                |

  Scenario: Closing using clicks on targets
    Given I am on "http://learn.code.org/s/1/level/2?noautoplay=true"
    And I rotate to landscape
    And I press "x-close"
    And callout "0" is visible
    And callout "1" is visible
    And I press "runButton"
    And callout "1" is hidden
    And I click block "1"
    And callout "0" is hidden

  Scenario: Opening the Show Code dialog
    When I press "show-code-header"
    Then ".modal-backdrop" should be in front of "#qtip-0"
  