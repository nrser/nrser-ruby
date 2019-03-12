Feature: Memoize in instance variables with {NRSER::Decorate::LazyAttr}
  
  Background:
    Given I require "nrser/decorate/lazy_attr"
  
  Scenario: (1) Lazy decorate an instance method
    
    Given a class:
      """ruby
      class LazyClass
        
        extend NRSER::Decorate
        
        attr_reader :count
        
        def initialize
          @count = 0
        end
        
        decorate NRSER::Decorate::LazyAttr,
        def f
          @count += 1
          'eff!'
        end
        
      end
      """
    
    When I create a new instance of {LazyClass} with no arguments
    
    # In the beginning, the method body has been called 0 times
    Then the instance has a `count` attribute that is 0
    
    # And the `@f` instance variable is not defined
    When I call `instance_variable_defined?` with "@f"
    Then the response is `false`
    
    # Let's make the first call
    When I call `f` on the instance with no arguments
    
    # We should get the response from the method body
    Then the response is equal to "eff!"
    
    # And see that it has been invoked once
    And the instance has a `count` attribute that is 1
    
    # The `@f` instance variable has also been set
    When I call `instance_variable_defined?` with "@f"
    Then the response is `true`
    
    # And it's value is the method's response
    When I call `instance_variable_get` on the instance with "@f"
    Then the response is equal to "eff!"
    
    # Ok, let's call again...
    When I call `f` on the instance with no arguments
    
    # Still the same!
    Then the response is equal to "eff!"
    And the instance has a `count` attribute that is 1
    
    When I call `instance_variable_defined?` with "@f"
    Then the response is `true`
    
    When I call `instance_variable_get` on the instance with "@f"
    Then the response is equal to "eff!"
  

  Scenario: (2) Lazy decorate a singleton method
    
    Given a class:
      """ruby
      class LazyClass
        
        extend NRSER::Decorate
        
        @count = 0
        
        def self.count
          @count
        end
        
        decorate_singleton NRSER::Decorate::LazyAttr,
        def self.f
          @count += 1
          'eff!'
        end
        
      end
      """
    
    # In the beginning, the method body has been called 0 times
    Then the class has a `count` attribute that is 0
    
    # And the `@f` instance variable is not defined
    When I call `instance_variable_defined?` on the class with "@f"
    Then the response is `false`
    
    # Let's make the first call
    When I call `f` on the class with no arguments
    
    # We should get the response from the method body
    Then the response is equal to "eff!"
    
    # And see that it has been invoked once
    And the class has a `count` attribute that is 1
    
    # The `@f` instance variable has also been set
    When I call `instance_variable_defined?` on the class with "@f"
    Then the response is `true`
    
    # And it's value is the method's response
    When I call `instance_variable_get` on the class with "@f"
    Then the response is equal to "eff!"
    
    # Ok, let's call again...
    When I call `f` on the class with no arguments
    
    # Still the same!
    Then the response is equal to "eff!"
    And the class has a `count` attribute that is 1
    
    When I call `instance_variable_defined?` on the class with "@f"
    Then the response is `true`
    
    When I call `instance_variable_get` on the class with "@f"
    Then the response is equal to "eff!"

  
  Scenario: (3) Raises when it can detect the the target takes arguments
    
    Since {NRSER::Decorate::LazyAttr} is for wrapping attribute methods, which 
    accept no arguments, it raises when attempting to decorate a method that
    has parameters.
    
    Given a class:
      """ruby
      class LazyClass
        
        extend NRSER::Decorate
        
        def f x
          "f of x"
        end
        
      end
      """
      
    When I call {LazyClass.decorate} with {NRSER::Decorate::LazyAttr}
    
    Then an {ArgumentError} is raised
      
