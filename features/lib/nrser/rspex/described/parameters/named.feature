Feature: Describe parameters by name
  
  Scenario: Positional parameters by name
    
    TODO
        
    Given a module:
      """ruby
      module M
        def self.add x, y
          x + y
        end
      end
      """
    
    And the module's method {.add}
    
    And the parameters:
      | NAME  | VALUE |
      | x     | `1`   |
      | y     | `2`   |
    
    When I call the method with the parameters
    
    Then the response is `3`
    
    # And the parameters `{hey: "ho", lets: "go"}`
    
    # TODO  Subject resolution needs to be refactored so that these lines can
    #       appear in **EITHER** order..!
    #       
    # When the `obj` parameter is `{hey: "ho", lets: "go"}`
    # And I call it
    
    # When I call the method with the parameters
    
    # Then the response is equal to "{\"hey\":\"ho\",\"lets\":\"go\"}"