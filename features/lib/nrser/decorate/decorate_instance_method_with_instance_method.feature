Feature: Decorate an instance method with an instance method
  
  Scenario: Both are referenced by {Symbol} name
    Given a class:
      """ruby
      class A
        extend NRSER::Decorate
        
        def decorator receiver, target, *args, &block
          ~%{ A#decorator called #{ target.name } and it said:
              #{ target.call *args, &block } }
        end
        
        def f
          "Hi from f :)"
        end
        
        decorate :decorator, :f
        
      end
      """
    
    When I create a new instance of `A`
    And I call `f`
    Then it responds with "A#decorator called f and it said: Hi from f :)"
  
  
  Scenario: Both are referenced by {String} name
    Given a class:
      """ruby
      class A
        extend NRSER::Decorate
        
        def decorator receiver, target, *args, &block
          ~%{ A#decorator called #{ target.name } and it said:
              #{ target.call *args, &block } }
        end
        
        def f
          "Hi from f :)"
        end
        
        decorate 'decorator', 'f'
        
      end
      """
    
    When I create a new instance of `A`
    And I call `f`
    Then it responds with "A#decorator called f and it said: Hi from f :)"
  
  
  Scenario: Decorator instance method is referenced as an {UnboundMethod}
    Given a class:
      """ruby
      class A
        extend NRSER::Decorate
        
        def decorator receiver, target, *args, &block
          ~%{ A#decorator called #{ target.name } and it said:
              #{ target.call *args, &block } }
        end
        
        decorate instance_method( :decorator ),
        def f
          "Hi from f :)"
        end
        
      end
      """
    
    When I create a new instance of `A`
    And I call `f`
    Then it responds with "A#decorator called f and it said: Hi from f :)"
    
    