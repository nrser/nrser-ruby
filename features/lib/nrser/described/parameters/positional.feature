Feature: Describe positional arguments 
  
  Purely positional arguments for method calls can be described in-line with
  comma-separated lists of quoted strings and expressions, or as rows in
  single-column tables.
  
  Scenario: Using quoted strings in-line
    
    Quoted strings can be written as usual (though they are fed through `eval`
    internally like expressions).
    
    Given the method {::File.join}
    And the arguments "/", 'var', "log", 'blah.log'
    
    When I call the method with the arguments
    
    Then the response is equal to "/var/log/blah.log"
  
  
  Scenario: Using backtick-quoted expressions in-line
    
    Ruby code can be provided between backticks, which will be passed to `eval`
    to produce the argument values.
    
    NOTE  At the moment you **can not use backticks (`) *inside* expressions**.
    
    Given the method {::Array.[]}
    
    # These should make sense. You can of course put quoted strings *inside* 
    # backtick expressions if you want to for some reason.
    And the arguments `:a`, `1`, `"hey"`, `[ 2, 3 ].reduce &:+`
    
    # The "with the arguments" suffix is cosmetic and can be omitted
    When I call the method
    
    Then the response is equal to `[:a, 1, "hey", 5]`
  
  
  Scenario: Using rows of a single-column table
    
    The same in-line formats are accepted.
    
    NOTE  At the moment you **can not use backticks (`) *inside* expressions**.
    
    Given the method {::Array.[]}
    
    # These should make sense. You can of course put quoted strings *inside* 
    # backtick expressions if you want to for some reason.
    # 
    # NOTE  The column heading must be present, but may be anything.
    # 
    And the arguments:
      | VALUE                 |
      | `:a`                  |
      | `1`                   |
      | "hey"                 |
      | `[ 2, 3 ].reduce &:+` |
    
    # The "with the arguments" suffix is cosmetic and can be omitted
    When I call the method
    
    Then the response is equal to `[:a, 1, "hey", 5]`
