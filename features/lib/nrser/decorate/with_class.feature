Feature: Decorate with a {Class}
  
  Background:
    Given I require 'nrser/decorate'
  
  
  Scenario: (1) Decorate an instance method with a (non-callable) {Class}
    
    You can use the class object itself as the decorator, and - as long as *it*
    is not callable (does not respond to `#call`) - an instance will be
    constructed automatically to handle the calls.
    
    Given a class:
      """ruby
      
      class Decorator
        def call receiver, target, *args, &block
          <<~END
            Decorator#call called #{ target.name } and it said:
            #{ target.call *args, &block }
          END
        end
      end
      
      """
    
    And a class:
      """ruby
      
      class A
        extend NRSER::Decorate
        
        decorate Decorator,
        def f *args, &block
          "Hi from f :)"
        end
        
      end
      
      """
          
    When I create a new instance of {A} with no parameters
    And I call `f` with no parameters
    
    Then the response is equal to:
      """ruby
      
        <<~END
          Decorator#call called f and it said:
          Hi from f :)
        END
      
      """
      
      
  Scenario: (2) Decorate an instance method with a {Class} instance
    
    You can also construct the instance yourself, on the spot or otherwise, and
    use that to decorate (works for any `#call`-able).
    
    Given a class:
      """ruby
      
      class Decorator
        def initialize value
          @value = value
        end
        
        def call receiver, target, *args, &block
          <<~END
            Decorator#call with value #{ @value } called #{ target.name } and it said:
            #{ target.call *args, &block }
          END
        end
      end
      
      """
    
    And a class:
      """ruby
      
      class A
        extend NRSER::Decorate
        
        decorate Decorator.new( 1 ),
        def f *args, &block
          "Hi from f :)"
        end
        
      end
      
      """
          
    When I create a new instance of {A} with no parameters
    And I call `f` with no parameters
    
    Then the response is equal to:
      """ruby
      
        <<~END
          Decorator#call with value 1 called f and it said:
          Hi from f :)
        END
      
      """
    
    
  Scenario: (3) Decorate with a class that responds to `#call`
    Given a class:
      """ruby
      class Decorator
        def self.call receiver, target, *args, &block
          <<~END
            Decorator.call called #{ target.name } and it said:
            #{ target.call *args, &block }
          END
        end
        
        def initialize
          raise "Should not happen!"
        end
      end
      """
      
    And a class:
      """ruby
      class A
        extend NRSER::Decorate
        
        decorate Decorator,
        def f *args, &block
          "Hi from f :)"
        end
        
      end
      """
          
    When I create a new instance of {A} with no parameters
    And I call `f` with no parameters
    
    Then the response is equal to:
      """ruby
      
        <<~END
          Decorator.call called f and it said:
          Hi from f :)
        END
      
      """
