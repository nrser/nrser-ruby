Feature: Check out option defaults work on {NRSER::Text::Renderer::Options}

  Background:
    Given I require "nrser/text/renderer/options"
    And the class {NRSER::Text::Renderer::Options}
  
  
  Scenario Outline: (1) Check the simple (identity) default option values
    
    Given I construct an instance of the class with no arguments
    
    Then the instance has an `<NAME>` attribute
    And it is `<VALUE>`
    
    Examples:
      | NAME              | VALUE |
      | color?            | false |
      | word_wrap         | false |
      | list_indent       | 4     |
      | list_header_depth | 3     |
      | code_indent       | 4     |
      

  Scenario: (2) Check more complex default option values
    
    Given I construct an instance of the class with no arguments
    
    Then the instance has an `no_preceding_space_chars` attribute
    And it is equal to `[ ',', ';', ':', '.', '?', '!' ]`
