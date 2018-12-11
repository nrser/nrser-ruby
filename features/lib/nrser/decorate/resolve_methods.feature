Feature: Resolve methods by *bare* or *qualified* name
  
  {NRSER::Decorate#resolve_method} is used internally to resolve {String} and
  {Symbol} method names to {Method} and {UnboundMethod} objects.
  
  Background:
    Given a class:
      """ruby
      class A
        extend NRSER::Decorate
        
        def self.my_singleton_method; end
        
        def my_instance_method; end
      end
      """
  
  Scenario: Name is a *qualified* singleton method
    When I call {A.resolve_method}
    And the `name:` parameter is ".my_singleton_method"
    
    Then the response is a {Method}
    
    And it has a `name` attribute that is `:my_singleton_method`
    
    And it has a `receiver` attribute that is {A}
  