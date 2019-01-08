Feature: Reference decorator and decorated methods by name
  
  Both decorator and decorated methods may be referenced by name, as either 
  {Symbol} or {String} instances. The referenced methods may be instance or 
  singleton (class) methods, as long as they are unambiguous.
  
  Background:
    Given I require "nrser/decorate"
  
  Scenario: Instance methods referenced by "bare" name
    
    Using {NRSER::Decorate#decorate}, methods that are referenced by "bare"
    name - {String} or {Symbol} without a preceeding '.' or '#' to indicate
    that they are singleton or instance methods - are assumed to be instance
    methods.
    
    Given a class:
      """ruby
      class A
        extend NRSER::Decorate
        
        def decorator receiver, target, *args, &block
          ~%{ A#decorator called #{ target.name } and it said:
              #{ target.call *args, &block } }
        end
        
        def f
          "Hi from A#f!"
        end
        
        decorate :decorator, :f
        
      end
      """
    
    When I create a new instance of {A} with no parameters
    And I call `f` with no parameters
    
    Then the response is equal to "A#decorator called f and it said: Hi from A#f!"
    
    
  Scenario: Singleton methods referenced by "bare" name
    
    Using {NRSER::Decorate#decorate_singleton}, methods that are referenced
    by "bare" name - {String} or {Symbol} without a preceeding '.' or '#' to
    indicate that they are singleton or instance methods - are assumed to be
    singleton methods.
    
    Given a class:
      """ruby
      class A
        extend NRSER::Decorate
        
        def self.decorator receiver, target, *args, &block
          ~%{ A.decorator called #{ target.name } and it said:
              #{ target.call *args, &block } }
        end
        
        def self.f
          "Hi from A.f!"
        end
        
        decorate_singleton :decorator, :f
        
      end
      """
    
    And I call {A.f} with no parameters
    Then the response is equal to "A.decorator called f and it said: Hi from A.f!"
