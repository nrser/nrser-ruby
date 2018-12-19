Feature: Describe a {::Method} using {NRSER::RSpex::Described::Method}
  
  Scenario: Of a {::Class} from the lib, using the bare method name
    
    Given the class {::NRSER::RSpex::Described::Base}
    And the class' method `default_human_name`
    
    Then the method is a {::Method}
    And it has a `name` attribute equal to `:default_human_name`
  
  
  Scenario: Of a {::Class} from the lib, using '.'-prefixed method name
    
    Given the class {::NRSER::RSpex::Described::Base}
    And the class' method {.default_human_name}
    
    Then the method is a {::Method}
    And it has a `name` attribute equal to `:default_human_name`
  
    