Feature: Describe a class
  
  Scenario: Class created from a source code block
    
    Given a class:
      """ruby
      class A
      end
      """
    
    Then the class is a {::Class}
    And it is a {::Module}
    And it has a `name` attribute that is a {::String}
  
  
  Scenario: Class defined in the lib
    
    Given the class {::NRSER::RSpex::Described::Class}
    
    Then the class is a {::Class}
    And it is a {::Module}
    And it has a `name` attribute equal to "NRSER::RSpex::Described::Class"
    And it is a subclass of {::NRSER::RSpex::Described::Base}
    