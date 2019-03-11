Feature: Compact repeated blank lines with {NRSER::Ext::String#compact_blank_lines}

  Background:
    Given I require 'nrser/ext/string/text/words'
    And the instance method {NRSER::Ext::String#words}
  
  Scenario Outline: (1) Basics
    
    Given the string <string>
    
    When I bind the instance method to the string 
    And I call the method with no parameters
    
    Then the response is equal to `<response>`
    
    Examples:
      | string         | response             |
      | "some-words"   | [ "some", "words" ]  |
      | "NRSER"        | [ "NRSER" ]          |
      | "NRSER::Text"  | [ "NRSER", "Text" ]  |
      | "NRSER::RSpex" | [ "NRSER", "RSpex" ] |