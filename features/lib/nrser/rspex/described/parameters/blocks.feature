Feature: Describe parameters by name
  
  Scenario: Describing the block parameters as a step
    
    Since there can be only one block parameter, you can describe it with a
    generic step.
    
    Given the object `[ 1, 2, 3, 4]`
    And the object's method `map`
    And the block parameter is `->( n ) { n.even? }`
    
    When I call the method with the parameters
    
    Then the response is equal to `[ false, true, false, true ]`
  
  
  Scenario: Describing the block parameter by name
    
    You can also describe the block parameter by name, using a '&' prefix.
    
    NOTE  The *name* of the block parameter is ignored at the moment, since 
          there is only one block parameter possible. In the future, it may
          issue a warning to help you correct the name in your features.
    
    Given a module:
      """ruby
      module M
        def self.f x, &my_block
          my_block.call x
        end
      end
      """
    And the module's method `f`
    And the parameters:
      | NAME        | VALUE                       |
      | x           | `[ 1, 2, 3, 4 ]`            |
      | &my_block   | `->( x ) { x.map &:even? }` |
    
    When I call the method with the parameters
    
    Then the response is equal to `[ false, true, false, true ]`
  
  
  Scenario: Using unary `&` format to covert values to {::Proc}s (as step)
    
    The unary `&` format can be used in single-steps that describe the block
    parameter.
  
    Given the object `[ 1, 2, 3, 4 ]`
    And the object's method `map`
    And the block parameter is `&:even?`
    
    When I call the method
    
    Then the response is equal to `[ false, true, false, true ]`


  Scenario: Using unary `&` format in name/value parameter tables
    
    It can also be used in the value column of named parameter tables.
  
    Given the object `[ 1, 2, 3, 4 ]`
    And the object's method `map`
    And the parameters:
      | NAME        | VALUE             |
      | &block      | `&:even?`         |
    
    When I call the method
    
    Then the response is equal to `[ false, true, false, true ]`
    
    
  Scenario: Using unary `&` format in positional parameter tables
    
    Unary `&` format can be used in the **last** value row in single-column
    positional value tables to denote that the value is the block parameter.
    
    NOTE  This is (at this time) the **ONLY** way to describe a block parameter
          in positional value tables. Otherwise we have no way of knowing that
          the last parameter should be sent as a block!
  
    Given the object `[ 1, 2, 3, 4 ]`
    And the object's method `send`
    And the parameters:
      | VALUE       |
      | `:map`      |
      | `&:even?`   |
    
    When I call the method
    
    Then the response is equal to `[ false, true, false, true ]`

  
  Scenario: Using unary `&` format in in-line parameter lists
    
    Unary `&` format can be used in the **last** value row in single-column
    positional value tables to denote that the value is the block parameter.
    
    NOTE  This is (at this time) the **ONLY** way to describe a block parameter
          in in-line positional value lists. Otherwise we have no way of knowing
          that the last parameter should be sent as a block!
  
    Given the object `[ 1, 2, 3, 4 ]`
    And the object's method `send`
    And the parameters `:map`, `&:even?`
    
    When I call the method
    
    Then the response is equal to `[ false, true, false, true ]`
