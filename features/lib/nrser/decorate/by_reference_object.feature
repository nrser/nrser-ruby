Feature: Reference decorator and decorated methods by reference object
  
  Both decorator and decorated methods may be referenced using corresponding
  {::Method} or {::UnboundMethod} instances. I imagine this will be less common
  than the other ways of identifying the methods, but, hey, it's there.
  
  The scenarios are mostly to make sure everything works as intended, and forgo
  accompanying explanations, but if you've reviewed the other features they 
  should be easy enough to follow.
  
  Background:
    
    Using the same setup I used in the "by name" scenarios; check over there 
    for details.
    
    And a class:
      """ruby
      require 'nrser/decorate'
      
      class A
        
        extend NRSER::Decorate
        
        def self.singleton_decorator target, *args, &block
          <<~END
            A.singleton_decorator called #{ target.name } and it said:
            #{ target.call( *args, &block ) }
          END
        end
        
        def self.singleton_target
          "Hi from A.singleton_target"
        end
        
        def instance_decorator target, *args, &block
          <<~END
            A#instance_decorator called #{ target.name } and it said:
            #{ target.call( *args, &block ) }
          END
        end
        
        def instance_target
          "Hi from A#instance_target"
        end
        
      end
      """
  
  
  Scenario: (1) Decorate an {UnboundMethod} with another
    
    Given I evaluate the following in the class {A}:
      """ruby
      decorate  instance_method( :instance_decorator ),
                instance_method( :instance_target )
      """
    
    When I create a new instance of {A} with no arguments
    And I call `instance_target` with no arguments
    
    Then the response is equal to:
      """ruby
      <<~END
        A#instance_decorator called instance_target and it said:
        Hi from A#instance_target
      END
      """
  
  
  Scenario: (2) Decorate a {Method} with another
    
    Given I evaluate the following in the class {A}:
      """ruby
      decorate  method( :singleton_decorator ),
                method( :singleton_target )
      """
    
    When I call {A.singleton_target} with no arguments
    
    Then the response is equal to:
      """ruby
      <<~END
        A.singleton_decorator called singleton_target and it said:
        Hi from A.singleton_target
      END
      """
  
  
  Scenario: (3) Decorate an {UnboundMethod} with a {Method}
    
    Given I evaluate the following in the class {A}:
      """ruby
      decorate  method( :singleton_decorator ),
                instance_method( :instance_target )
      """
    
    When I create a new instance of {A} with no arguments
    And I call `instance_target` with no arguments
    
    Then the response is equal to:
      """ruby
      <<~END
        A.singleton_decorator called instance_target and it said:
        Hi from A#instance_target
      END
      """
  