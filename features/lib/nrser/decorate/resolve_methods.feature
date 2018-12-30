Feature: Resolve methods by *bare* or *implicit* name
  
  {NRSER::Decorate#resolve_method} is used internally to resolve {String} and
  {Symbol} method names to {Method} and {UnboundMethod} objects.
  
  Background:
    Given a class:
      """ruby
      require 'nrser/decorate'
      
      class A
        extend NRSER::Decorate
        
        def self.my_singleton_method; end
        
        def my_instance_method; end
      end
      """
  
  
  Scenario: *Implicit* singleton method name
    Given the `name:` parameter is ".my_singleton_method"
    
    When I call {A.resolve_method}
    
    Then the response is a {::Method}
    And it has a `name` attribute that is `:my_singleton_method`
    And it has a `receiver` attribute that is {A}
  
  
  Scenario: *Implicit* instance method name
    Given the `name:` parameter is "#my_instance_method"
    
    When I call {A.resolve_method}
    
    Then the response is an {::UnboundMethod}
    And it has a `name` attribute that is `:my_instance_method`
    And it has a `owner` attribute that is {A}
  
  
  Scenario: *Bare* method name and singleton default type
    Given the `name:` parameter is "my_singleton_method"
    And the `default_type:` parameter is `:singleton`
    
    When I call {A.resolve_method}
    
    Then the response is a {::Method}
    And it has a `name` attribute that is `:my_singleton_method`
    And it has a `receiver` attribute that is {A}
  
  
  Scenario: *Bare* method name and class default type
    Given the `name:` parameter is "my_singleton_method"
    And the `default_type:` parameter is `:class`
    
    When I call {A.resolve_method}
    
    Then the response is a {::Method}
    And it has a `name` attribute that is `:my_singleton_method`
    And it has a `receiver` attribute that is {A}
  
  
  Scenario: *Bare* method name and instance default type
    Given the `name:` parameter is "my_instance_method"
    And the `default_type:` parameter is `:instance`
    
    When I call {A.resolve_method}
    
    Then the response is a {::UnboundMethod}
    And it has a `name` attribute that is `:my_instance_method`
    And it has a `owner` attribute that is {A}
  
  
  Scenario: *Bare* method name and no default type
    Given the `name:` parameter is "my_instance_method"
    And the `default_type:` parameter is `nil`
    
    When I call {A.resolve_method}
    
    Then a {NRSER::ArgumentError} is raised
    And the error has a `context` attribute
    And the attribute has a `:name` key with value "my_instance_method"
  