Feature: Decorate with a {Proc}

  Background:
    
    Given I require 'nrser/decorate'
  
  
  Scenario: Decorate an instance method with a {Proc}
    Given a class:
      """ruby
      
      class A
      
        extend NRSER::Decorate
        
        decorate ->( target, *args, &block ) {
          ~%{ Proc called #{ target.name } and it said:
              #{ target.call *args, &block } }  
        },
        def f
          "Hi from f :)"
        end
        
      end
      
      """
    
    When I create a new instance of {A} with no arguments
    And I call `f` with no arguments
    Then the response is equal to "Proc called f and it said: Hi from f :)"
  
  
  Scenario: Decorate a singleton method with a {Proc}
    Given a class:
      """ruby
      
      class A
      
        extend NRSER::Decorate
        
        decorate_singleton ->( target, *args, &block ) {
          ~%{ Proc called #{ target.name } and it said:
              #{ target.call *args, &block } }  
        },
        def self.f
          "Hi from f :)"
        end
        
      end
      
      """
    
    When I call {A.f} with no arguments
    Then the response is equal to "Proc called f and it said: Hi from f :)"