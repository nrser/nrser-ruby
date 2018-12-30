Feature: Describe attributes
  
  Scenario: "In order"
    
    Given the object 1
    And the attribute `to_s`
    
    Then the attribute is equal to "1"
