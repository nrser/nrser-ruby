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
    
    Then the instance has a `count` attribute that is `1`
    And it has a `<key>` key with value `<value>`
    
    Examples:
      | key            | value   |
      | "x"            | "ex"    |
      | 2              | "two"   |
      | { a: 1, b: 2 } | "three" |
    
  
  @focus
  Scenario Outline: (2) I set *different* keys in the same instance
    
    When I construct an instance of the class with no parameters
    And I call `[]=` with `<key_1>`, `<value_1>`
    And I call `[]=` with `<key_2>`, `<value_2>`
    
    Then the instance has a `count` attribute that is `2`
    And it has a `<key_1>` key with value `<value_1>`
    And it has a `<key_2>` key with value `<value_2>`
    
    Examples:
      | key_1          | value_1 | key_2         | value_2 |
      | "x"            | "ex"    | "y"           | "why?"  |
      | 2              | "two"   | "three"       | 3       |
      | { a: 1, b: 2 } | "three" | {a: 3, b: 4 } | "four"  |
    