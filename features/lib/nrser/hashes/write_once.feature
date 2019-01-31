Feature: {NRSER::Hashes::WriteOnce} only allows keys to be written once

  Background:
    Given I require "nrser/hashes/write_once"
    And the class {NRSER::Hashes::WriteOnce}
  
  Scenario: (1) I construct an empty instance
    
    When I construct an instance of the class with no parameters
    
    Then the instance is an instance of the class
    And it has an `empty?` attribute that is `true`
  
  
  Scenario Outline: (2) I set keys in empty instances
    
    When I construct an instance of the class with no parameters
    And I call `[]=` with `<key>`, `<value>`
    
    # Then the response is equal to `<value>`
    Then the instance has a `count` attribute that is `1`
    And it has a `<key>` key with value `<value>`
    
    Examples:
      | key | value |
      | "x" | "ex"  |
    