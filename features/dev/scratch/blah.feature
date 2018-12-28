Feature: Do some shit
  
  Scenario: Describe a class defined in the lib
    
    Given the class {::NRSER::Described::Class}
    
    Then the class is a {::Class}
    And it is a {::Module}
    # And it has a `name` attribute equal to "NRSER::Described::Class"
    # And it is a subclass of {::NRSER::Described::Base}
  
  Scenario: Describe some params
    
    Given the method {::File.join}
    And the parameters "/", 'var', "log", 'blah.log'
    
    When I call the method with the parameters
    
    Then the response is equal to "/var/log/blah.log"
    