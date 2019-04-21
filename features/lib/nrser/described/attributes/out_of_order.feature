@lazy
Feature: Describe attributes "out of order"
  
  {NRSER::Described} supports *out-of-order* descriptions, allowing you to 
  describe an attribute in the background, then describe different objects
  with that attribute in each scenario.
  
  Background:
    We can use this attribute description on objects described in later steps.
    
    Given the attribute `to_s`
  
  
  Scenario: (1) Describe an object and check its {#to_s} value
    
    Now we describe an object - the number `1` - and check that the attribute
    is what we expect it to be.
  
    Given the object 1
    
    # Explicitly identifying "the attribute" is crucial here, see (3)
    Then the attribute is equal to "1"
  
  
  Scenario: (2) Describe a different object and check its {#to_s} value
    
    We can then describe other objects in other scenarios, and check that 
    their attribute is what we expect.
  
    Given the object `Pathname.new '/usr/bin'`
    
    # Explicitly identifying "the attribute" is crucial here, see (3)
    Then the attribute is equal to "/usr/bin"
  
  
  Scenario: (3) Implicit subject will refer to the most recent description
    
    In scenarios (1) and (2), explicitly identifying "the attribute" in the
    `Then` step is *crucial*: using the implicit "it" form will refer to the
    most recent description, which is "the object 1", *not* its {#to_s}
    attribute.
    
    Given the object 1
    
    # "it" will refer to the preceding description of the object 1, NOT its
    # {#to_s} attribute
    Then it is NOT equal to "1"
    
    # Which is the object's value: 1
    And it is 1
  