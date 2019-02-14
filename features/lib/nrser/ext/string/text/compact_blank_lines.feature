Feature: Compact repeated blank lines with {NRSER::Ext::String#compact_blank_lines}

  Background:
    Given I require 'nrser/ext/string/text/compact_blank_lines'
    And the instance method {NRSER::Ext::String#compact_blank_lines}
  
  Scenario: (1) 
    
    Given the string:
      """
      First
      
      
      Second
      
      """
    
    When I bind the instance method to the string 
    And I call the method with no parameters
    
    Then the response is equal to the string:
      """
      First
      
      Second
      
      """