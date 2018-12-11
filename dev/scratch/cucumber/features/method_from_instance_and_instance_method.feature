Feature: Method subject from instance and instance method
  
  Background:
    Given the module {Mica}
    
    And the module's class {Cat}
    # And its class {Cat}
    
    And the class' instance method {#pretty?}
    # And its instance method {#pretty?}

  Scenario: American Shorthair
    When I construct an instance (of the class)
    
    And the (constructor's) `breed:` paramter is "American Shorthair"
    
    # "the method" is the trigger that causes the subject {Described::Method} 
    # to be assembled from the tree.
    And I call the (instance) method
    
    Then the response is `true`
    Then it is `true`
    Then the response equals "blah"
    # Then I expect it is `true`
  
  Scenario: 
    Then it is an {UnboundMethod}
  
  
  
  Feature: Method subject from instance and instance method
  
  Background:
    Given the instance method {Mica::Cat#pretty?}

  Scenario: American Shorthair
    When I construct an instance
    And the `breed:` paramter is "American Shorthair"
    And call the method
    Then the result is `true`
  
  Scenario: Bengal
    When I construct an instance
    And the `breed:` paramter is "Bengal"
    And I call the method
    #   I call it
    Then  it is `true`
    #     it responds with `true`