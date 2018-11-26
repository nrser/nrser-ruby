Feature: Decorate an instance method with a singleton method
  
  Scenario: Both methods are referenced by {Symbol} name
    Given a class:
      """ruby
      class A
        extend NRSER::Decorate
        
        def self.decorator receiver, target, *args, &block
          {
            method: __method__,
            receiver: receiver,
            target: target,
            args: args,
            block: block,
            target_response: target.call( *args, &block ),
          }
        end
        
        def f *args, &block
          {
            method: __method__,
            args: args,
            block: block,
          } 
        end
        
        decorate :decorator, :f
        
      end
      """
    
    When I create a new instance of `A`
    And call `f`
    Then the response includes:
      | KEY                     | VALUE       |
      | method                  | :decorator  |
      | receiver                | @instance   |
      | args                    | []          |
      | block                   | nil         |
      | target_response.method  | :f          |
      | target_response.args    | []          |
      | target_response.block   | nil         |
  
  
  Scenario: Both are referenced by {String} name
    Given a class:
      """ruby
      class A
        extend NRSER::Decorate
        
        def self.decorator receiver, target, *args, &block
          ~%{ A.decorator called #{ target.name } and it said:
              #{ target.call *args, &block } }
        end
        
        def f
          "Hi from f :)"
        end
        
        decorate 'decorator', 'f'
        
      end
      """
    
    When I create a new instance of `A`
    And call `f`
    Then it responds with "A.decorator called f and it said: Hi from f :)"
  
  
  Scenario: Decorated instance method is referenced using the def
    Given a class:
      """ruby
      class A
        extend NRSER::Decorate
        
        def self.decorator receiver, target, *args, &block
          ~%{ A.decorator called #{ target.name } and it said:
              #{ target.call *args, &block } }
        end
        
        decorate :decorator,
        def f
          "Hello from f!"
        end
        
      end
      """
    
    When I create a new instance of `A`
    And call `f`
    Then it responds with "A.decorator called f and it said: Hello from f!"
  
  
  Scenario: Decorated instance method is referenced as an {UnboundMethod}
    Given a class:
      """ruby
      class A
        extend NRSER::Decorate
        
        def self.decorator receiver, target, *args, &block
          ~%{ A.decorator called #{ target.name } and it said:
              #{ target.call *args, &block } }
        end
        
        def f
          "Hey there, I'm f!"
        end
        
        decorate :decorator, instance_method( :f )
        
      end
      """
    
    When I create a new instance of `A`
    And call `f`
    Then it responds with "A.decorator called f and it said: Hey there, I'm f!"
    
    
  Scenario: Decorator singleton method is referenced as a {Method}
    Given a class:
      """ruby
      class A
        extend NRSER::Decorate
        
        def self.decorator receiver, target, *args, &block
          ~%{ A.decorator called #{ target.name } and it said:
              #{ target.call *args, &block } }
        end
        
        def f
          "f f f f..."
        end
        
        decorate method( :decorator ), :f
        
      end
      """
    
    When I create a new instance of `A`
    And call `f`
    Then it responds with "A.decorator called f and it said: f f f f..."
  
  
    
  Scenario: Decorate with two singleton methods
    Given a class:
      """ruby
      class A
        extend NRSER::Decorate
        
        def self.decorator_1 receiver, target, *args, &block
          "A.decorator_1, #{ target.call *args, &block }"
        end
        
        def self.decorator_2 receiver, target, *args, &block
          "A.decorator_2, #{ target.call *args, &block }"
        end
        
        decorate  :decorator_1,
                  :decorator_2,
        # The target instance method.
        # 
        # @return [Stirng]
        # 
        def f
          "A#f."
        end
        
      end
      """
    
    When I create a new instance of `A`
    And call `f`
    Then it responds with "A.decorator_1, A.decorator_2, A#f."
