Feature: Describe parameters used in a method call
  
  TDDO
  
  
  Scenario: TODO
    
    TODO
    
    Given the method {::File.join}
    And the parameters "/", "var", "log", "blah.log"
    
    When I call the method with the parameters
    
    Then the response is equal to "/var/log/blah.log"
  
  
  Scenario: TODO
    
    TODO
    
    Given the method {::Array.[]}
    And the parameters `:a`, `1`, `[ 2, 3 ].reduce &:+`
    
    # The "with the parameters" suffix is cosmetic and can be omitted
    When I call the method
    
    Then the response is equal to `[:a, 1, 5]`
  
  
  # Scenario: Positional parameters by name
    
  #   TODO
        
  #   Given the module:
  #     """ruby
  #     module M
  #       def self.add x, y
  #         x + y
  #       end
  #     end
  #     """
    
  #   And the module's method {.add}
    
  #   And the parameters:
  #     | x | 1 |
  #     | y | 2 |
    
  #   When I call the method with the parameters
    
  #   Then the response is `3`
    
  #   # And the parameters `{hey: "ho", lets: "go"}`
    
  #   # TODO  Subject resolution needs to be refactored so that these lines can
  #   #       appear in **EITHER** order..!
  #   #       
  #   # When the `obj` parameter is `{hey: "ho", lets: "go"}`
  #   # And I call it
    
  #   When I call the method with the parameters
    
  #   Then the response is equal to "{\"hey\":\"ho\",\"lets\":\"go\"}"