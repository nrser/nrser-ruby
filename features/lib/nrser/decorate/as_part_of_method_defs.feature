Feature: Decorate as part of method definitions
  
  This is the form in which I imagine myself decorating most. It does it's best
  to imitate languages with '@'-style syntactic decorators like Java, Python,
  and probably most languages invented in the last ten years that are used by
  developers that didn't also write them (with the notable exception of Elixir,
  which has fashioned itself much after Ruby in an attempt to fill the gap for
  folks that have finally nailed down how to deploy Rails after all these years,
  and Googlelang from the flesh-bots that were concerned their logo might be a
  bit too rowdy and fun, much less a sugary special syntax for something you can
  easily do and do again and do again and again in a multi-line format).
  
  So now that we've had our fun I'll drop ya into some examples; you'll get the
  idea.
  
  Background:
    
    Here we got a class with singleton and instance decorator methods that we
    will use throughout.
    
    And a class:
      """ruby
      require 'nrser/decorate'
      
      class A
        
        extend NRSER::Decorate
        
        def self.singleton_decorator receiver, target, *args, &block
          <<~END
            A.singleton_decorator called #{ target.name } and it said:
            #{ target.call( *args, &block ) }
          END
        end
        
        def instance_decorator receiver, target, *args, &block
          <<~END
            A#instance_decorator called #{ target.name } and it said:
            #{ target.call( *args, &block ) }
          END
        end
        
      end
      """
  
  
  Scenario: (1) Decorate an instance method with another
    
    So, as you can see in the source below, we start our decorator form, and
    leave a trailing comma after the decorator method name, letting
    {NRSER::Decorate#decorate} receive the {::Symbol} that `def` returns after
    adding the method, which `decorate` will use just like the symbols in the
    "by name" examples.
    
    Given I evaluate the following in the class {A}:
      """ruby
      
      # Can maybe do some YARD macro crap up here to get info into docs about
      # the decoration?
      # 
      # @note You **NEED** that trailing comma!
      # 
      decorate :instance_decorator,
      # 
      # And here's the method. It says hi!
      # 
      # @return [String]
      # 
      def instance_target
        "Hi from A##{ __method__ }"
      end
      
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
      
  
  Scenario: (2) Decorate a singleton method with another
    
    Similar to (1), but we need to use `singleton_decorator`.
    
    Given I evaluate the following in the class {A}:
      """ruby
      
      decorate_singleton :singleton_decorator,
      # 
      # And here's the method. It says hi!
      # 
      # @return [String]
      # 
      def self.singleton_target
        "Hi from A.#{ __method__ }"
      end
      
      """
    
    And I call {A.singleton_target} with no arguments
    
    Then the response is equal to:
      """ruby
      <<~END
        A.singleton_decorator called singleton_target and it said:
        Hi from A.singleton_target
      END
      """
  
  
  Scenario: (3) Decorate an instance method with a singleton
    
    Yes we can! The same sort of way we did in the
    {requirements::features::lib::nrser::decorate::by_name
      "by name"} and
    {requirements::features::lib::nrser::decorate::by_reference_object
      "by reference object"} features.
    
    Given I evaluate the following in the class {A}:
      """ruby
      
      decorate :'.singleton_decorator',
      def instance_target_1
        "Hi from A##{ __method__ }"
      end
      
      decorate method( :singleton_decorator ),
      def instance_target_2
        "Hi from A##{ __method__ }"
      end
      
      """
    
    When I create a new instance of {A} with no arguments
    
    Given the instance's method `instance_target_1`
    When I call it with no arguments
    
    Then the response is equal to:
      """ruby
      <<~END
        A.singleton_decorator called instance_target_1 and it said:
        Hi from A#instance_target_1
      END
      """
    
    Given the instance's method `instance_target_2`
    And I call it with no arguments
    
    Then the response is equal to:
      """ruby
      <<~END
        A.singleton_decorator called instance_target_2 and it said:
        Hi from A#instance_target_2
      END
      """