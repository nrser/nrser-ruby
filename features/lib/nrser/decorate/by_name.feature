Feature: Reference decorator and decorated methods by name
  
  Both decorator and decorated methods may be referenced by name, as either 
  {Symbol} or {String} instances. The referenced methods may be instance or 
  singleton (class) methods, as long as they are unambiguous.
  
  
  Background:
    
    I will use the same simple class named {A} to demonstrate each scenario.
    
    The first things to notice is the I need to `require` the {NRSER::Decorate}
    module, and also *extend* it into {A}, making it's methods available as
    singleton methods.
    
    {A} contains each a singleton and instance decorator method, as well as 
    singleton and instance target methods that I will decorate.
    
    And a class:
      """ruby
      
      require 'nrser/decorate'
      
      class A
        
        extend NRSER::Decorate
        
        def self.singleton_decorator target, *args, &block
          <<~END
            A.singleton_decorator called #{ target.name } and it said:
            #{ target.call( *args, &block ) }
          END
        end
        
        def self.singleton_target
          "Hi from A.singleton_target"
        end
        
        def instance_decorator target, *args, &block
          <<~END
            A#instance_decorator called #{ target.name } and it said:
            #{ target.call( *args, &block ) }
          END
        end
        
        def instance_target
          "Hi from A#instance_target"
        end
        
      end
      """
  
  
  Scenario: (1) *Bare* names default to instance methods with `#decorate`
    
    Using {NRSER::Decorate#decorate}, methods that are referenced by "bare"
    name - {String} or {Symbol} without a preceding '.' or '#' to indicate
    that they are singleton or instance methods - are assumed to be instance
    methods.
    
    Given I evaluate the following in the class {A}:
      """ruby
        decorate :instance_decorator, :instance_target
      """
    
    When I create a new instance of {A} with no arguments
    And I call `instance_target` with no arguments
    
    Then the response is equal to:
      """ruby
        <<~END
          A#instance_decorator called instance_target and it said:
          Hi from A#instance_target
        END
      """
    
    
  Scenario: (2) *Bare* names default to instance methods with `#singleton_decorate`
    
    Using {NRSER::Decorate#decorate_singleton}, methods that are referenced
    by "bare" name - {String} or {Symbol} without a preceeding '.' or '#' to
    indicate that they are singleton or instance methods - are assumed to be
    singleton methods.
    
    Given I evaluate the following in the class {A}:
      """ruby
        decorate_singleton :singleton_decorator, :singleton_target
      """
    
    When I call {A.singleton_target} with no arguments
    
    Then the response is equal to:
      """ruby
        <<~END
          A.singleton_decorator called singleton_target and it said:
          Hi from A.singleton_target
        END
      """
  
  
  Scenario: (3) `#singleton_decorate` is the same as `default_type: :singleton`
    
    {NRSER::Decorate#decorate_singleton} simply calls {NRSER::Decorate#decorate}
    with an added `default_type: :singleton` keyword argument, which you can
    of course do yourself as well.
    
    Given I evaluate the following in the class {A}:
      """ruby
        decorate  :singleton_decorator,
                  :singleton_target,
                  default_type: :singleton
      """
    
    When I call {A.singleton_target} with no arguments
    
    Then the response is equal to:
      """ruby
        <<~END
          A.singleton_decorator called singleton_target and it said:
          Hi from A.singleton_target
        END
      """
  

  Scenario: (4) Decorating an instance method with a singleton
    
    If we want to decorate an instance method with a singleton when referencing
    them by name, we will need to add additional information so the library 
    knows what we're talking about.
    
    Since *bare* names default to instance methods names, we only need to 
    add information to the singleton method's name - a '.' prefix, like
    '.singleton_decorator' (strings or symbols is cool).
    
    Method names in this symbol-prefixed format are referred to as *implicit*
    names, since they denote their type but contain no explicit information
    about what module or class they belong to.
    
    Given I evaluate the following in the class {A}:
      """ruby
        decorate '.singleton_decorator', :instance_target
      """
    
    When I create a new instance of {A} with no arguments
    And I call `instance_target` with no arguments
    
    Then the response is equal to:
      """ruby
        <<~END
          A.singleton_decorator called instance_target and it said:
          Hi from A#instance_target
        END
      """

  Scenario: (5) *Implicit* instance method names
    
    You can use *implicit* instance method names as well, prefixing them with
    '#' like '#instance_decorator'. It doesn't work to decorate a singleton
    method with an instance one, for what should hopefully be obvious reasons,
    but I can show a usage just for completeness/kicks.
    
    Given I evaluate the following in the class {A}:
      """ruby
        decorate '.singleton_decorator', '#instance_target'
      """
    
    When I create a new instance of {A} with no arguments
    And I call `instance_target` with no arguments
    
    Then the response is equal to:
      """ruby
        <<~END
          A.singleton_decorator called instance_target and it said:
          Hi from A#instance_target
        END
      """
