Feature: Decorate a singleton method
  
  Scenario: With another singleton method
    Given a class:
      """ruby
      class A
        extend NRSER::Decorate
        
        def self.decorator receiver, target, *args, &block
          ~%{ A.decorator called #{ target.name } and it said:
              #{ target.call *args, &block } }
        end
        
        def self.f
          "Hi from f :)"
        end
        
        decorate :decorator, :f
        
      end
      """
    
    When I call `f`
    Then it responds with "A.decorator called f and it said: Hi from f :)"
  

