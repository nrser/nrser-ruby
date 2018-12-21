Feature: Describe parameters by name
  
  Scenario: Describing the block parameters as a step
    
    Given the object `[ 1, 2, 3, 4]`
    And the object's method `map`
    And the block parameter is `->( n ) { n.even? }`
    
    When I call the method with the parameters
    
    Then the response is equal to `[ false, true, false, true ]`
  