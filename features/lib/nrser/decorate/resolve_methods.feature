@lazy
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
    
    When I call {A.resolve_method}
  
  
  Scenario: *Implicit* singleton method name
    Given the `name:` argument is ".my_singleton_method"

    Then the response is a {::Method}
    And it has a `name` attribute that is `:my_singleton_method`
    And it has a `receiver` attribute that is {A}
  
  
  Scenario: *Implicit* instance method name
    Given the `name:` argument is "#my_instance_method"
    
    Then the response is an {::UnboundMethod}
    And it has a `name` attribute that is `:my_instance_method`
    And it has a `owner` attribute that is {A}
  
  
  Scenario: *Bare* method name and singleton default type
    Given the `name:` argument is "my_singleton_method"
    And the `default_type:` argument is `:singleton`
    
    Then the response is a {::Method}
    And it has a `name` attribute that is `:my_singleton_method`
    And it has a `receiver` attribute that is {A}
  
  
  Scenario: *Bare* method name and class default type
    Given the `name:` argument is "my_singleton_method"
    And the `default_type:` argument is `:class`
    
    Then the response is a {::Method}
    And it has a `name` attribute that is `:my_singleton_method`
    And it has a `receiver` attribute that is {A}
  
  
  Scenario: *Bare* method name and instance default type
    Given the `name:` argument is "my_instance_method"
    And the `default_type:` argument is `:instance`
    
    Then the response is a {::UnboundMethod}
    And it has a `name` attribute that is `:my_instance_method`
    And it has a `owner` attribute that is {A}
  
  
  Scenario: *Bare* method name and no default type
    Given the `name:` argument is "my_instance_method"
    And the `default_type:` argument is `nil`
    
    Then a {NRSER::ArgumentError} is raised
    And the error has a `context` attribute
    And the attribute has a `:name` key with value "my_instance_method"
  