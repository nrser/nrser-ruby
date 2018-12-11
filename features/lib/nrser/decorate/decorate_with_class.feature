Feature: Decorate with a {Class}
  
  Scenario: Decorate an instance method with a {Class} instance
    Given a class:
      """ruby
      class Decorator
        def call receiver, target, *args, &block
          ~%{ Decorator#call called #{ target.name } and it said:
              #{ target.call *args, &block } }  
        end
      end
      """
      
    And a class:
      """ruby
      class A
        extend NRSER::Decorate
        
        decorate Decorator.new,
        def f *args, &block
          "Hi from f :)"
        end
        
      end
      """
          
    When I create a new instance of `A`
    And I call `f`
    Then it responds with "Decorator#call called f and it said: Hi from f :)"
    
    
  Scenario: Decorate an instance method with a {Class} itself
    Given a class:
      """ruby
      class Decorator
        def call receiver, target, *args, &block
          ~%{ Decorator#call called #{ target.name } and it said:
              #{ target.call *args, &block } }  
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
          
    When I create a new instance of `A`
    And I call `f`
    Then it responds with "Decorator#call called f and it said: Hi from f :)"
