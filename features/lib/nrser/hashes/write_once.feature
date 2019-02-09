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
    
  
  Scenario Outline: (3) I set *different* keys in the same instance
    
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
      
  
  Scenario Outline: (4) I set *the same* keys in the same instance
    
    When I construct an instance of the class with no parameters
    And I call `[]=` with `<key>`, `<value_1>`
    
    Then the instance has a `count` attribute that is `1`
    And it has a `<key>` key with value `<value_1>`
    
    When I call `[]=` with `<key>`, `<value_2>`
    
    Then a {NRSER::KeyError} is raised
    And it has a `context` attribute
    And the attribute has a `:key` key with value `<key>`
    And it has a `:current_value` key with value `<value_1>`
    And it has a `:provided_value` key with value `<value_2>`
        
    Examples:
      | key            | value_1 | value_2 |
      | "x"            | "ex"    | "why?"  |
      | 2              | "two"   | 3       |
      | { a: 1, b: 2 } | "three" | "four"  |
  
  
  Scenario Outline: (5) I can not delete any set keys
    
    When I construct an instance of the class with no parameters
    And I call `[]=` with `<key>`, `<value>`
    
    Then the instance has a `count` attribute that is `1`
    And it has a `<key>` key with value `<value>`
    
    When I call `delete` with `<key>`
    
    Then a {::Exception} is raised
        
    Examples:
      | key            | value   |
      | "x"            | "ex"    |
      | 2              | "two"   |
      | { a: 1, b: 2 } | "three" |
    