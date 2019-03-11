Feature: {NRSER::Ext::Pathname#start_with?}

  Background:
    Given I require 'nrser/ext/pathname'
    And the instance method {NRSER::Ext::Pathname#start_with?}
  
  Scenario Outline: (1) 
    Given I construct an instance of {::Pathname} from <path>
    And I bind the instance method to the instance
    
    When I call the method with `Pathname.new <start>`
    
    Then the response is `<expected>`
  
    Examples:
      | path      | start   | expected  |
      | "a/b/c"   | "a/b"   | true      |
      | "a/b/c"   | "a/b/"  | true      |
      | "/a/b/c"  | "/"     | true      |
    