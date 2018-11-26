Feature: Decorate an instance method with a singleton method
  
  Scenario: Both methods are referenced by name
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
  
  