Feature: How does box work?

  Background:
    Given I require "nrser/text/terminal/box"
    
  Scenario:
    Given I let `box` be:
      """ruby
        NRSER::Text::Terminal::Box.
          new content: "X",
              background: "-",
              width: 4,
              height: 3
      """
    
    And I let `string` be `box.render`
    
    Then `string` is equal to the string:
      """
      X---
      ----
      ----
      """
    