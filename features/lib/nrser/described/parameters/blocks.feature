Feature: Describe arguments by name
  
  Scenario: Describing the block arguments as a step
    
    Since there can be only one block argument, you can describe it with a
    generic step.
    
    Given the object `[ 1, 2, 3, 4]`
    And the object's method `map`
    And the block argument is `->( n ) { n.even? }`
    
    When I call the method with the arguments
    
    Then the response is equal to `[ false, true, false, true ]`
  
  
  Scenario: Describing the block argument by name
    
    You can also describe the block argument by name, using a '&' prefix.
    
    NOTE  The *name* of the block argument is ignored at the moment, since 
          there is only one block argument possible. In the future, it may
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
    And the arguments:
      | NAME        | VALUE                       |
      | x           | `[ 1, 2, 3, 4 ]`            |
      | &my_block   | `->( x ) { x.map &:even? }` |
    
    When I call the method with the arguments
    
    Then the response is equal to `[ false, true, false, true ]`
  
  
  Scenario: Using unary `&` format to covert values to {::Proc}s (as step)
    
    The unary `&` format can be used in single-steps that describe the block
    argument.
  
    Given the object `[ 1, 2, 3, 4 ]`
    And the object's method `map`
    And the block argument is `&:even?`
    
    When I call the method
    
    Then the response is equal to `[ false, true, false, true ]`


  Scenario: Using unary `&` format in name/value argument tables
    
    It can also be used in the value column of named argument tables.
  
    Given the object `[ 1, 2, 3, 4 ]`
    And the object's method `map`
    And the arguments:
      | NAME        | VALUE             |
      | &block      | `&:even?`         |
    
    When I call the method
    
    Then the response is equal to `[ false, true, false, true ]`
    
    
  Scenario: Using unary `&` format in positional argument tables
    
    Unary `&` format can be used in the **last** value row in single-column
    positional value tables to denote that the value is the block argument.
    
    NOTE  This is (at this time) the **ONLY** way to describe a block argument
          in positional value tables. Otherwise we have no way of knowing that
          the last argument should be sent as a block!
  
    Given the object `[ 1, 2, 3, 4 ]`
    And the object's method `send`
    And the arguments:
      | VALUE       |
      | `:map`      |
      | `&:even?`   |
    
    When I call the method
    
    Then the response is equal to `[ false, true, false, true ]`

  
  Scenario: Using unary `&` format in in-line argument lists
    
    Unary `&` format can be used in the **last** value in in-line positional
    argument lists.
    
    NOTE  This is (at this time) the **ONLY** way to describe a block argument
          in in-line positional value lists. Otherwise we have no way of knowing
          that the last argument should be sent as a block!
  
    Given the object `[ 1, 2, 3, 4 ]`
    And the object's method `send`
    And the arguments `:map`, `&:even?`
    
    When I call the method
    
    Then the response is equal to `[ false, true, false, true ]`
