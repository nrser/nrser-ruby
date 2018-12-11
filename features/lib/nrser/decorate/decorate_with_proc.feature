Feature: Decorate with a {Proc}
  
  Scenario: Decorate an instance method with a {Proc}
    Given a class:
      """ruby
      class A
        extend NRSER::Decorate
        
        decorate ->( receiver, target, *args, &block ) {
          ~%{ Proc called #{ target.name } and it said:
              #{ target.call *args, &block } }  
        },
        def f
          "Hi from f :)"
        end
        
      end
      """
    
    When I create a new instance of `A`
    And I call `f`
    Then it responds with "Proc called f and it said: Hi from f :)"
  
  
  Scenario: Decorate a singleton method with a {Proc}
    Given a class:
      """ruby
      class A
        extend NRSER::Decorate
        
        decorate ->( receiver, target, *args, &block ) {
          ~%{ Proc called #{ target.name } and it said:
              #{ target.call *args, &block } }  
        },
        def self.f
          "Hi from f :)"
        end
        
      end
      """
    
    When I call `f`
    Then it responds with "Proc called f and it said: Hi from f :)"