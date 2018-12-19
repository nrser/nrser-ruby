Feature: Describe a method's response using {NRSER::RSpex::Described::Response}
  
  Scenario: lib {::Class}, singleton method, no parameters, implicit subject
    
    Given the class {::NRSER::RSpex::Described::Base}
    And the class' method `default_human_name`
    
    When I call it with no parameters
    
    Then it is equal to "base"
    