Feature: {NRSER::Meta::Names::Var::Global} matches global variable names
  
  By "Global", I mean "Starts with `$`" - there are a few pre-defined `$`-vars
  that are dynamically-set *locals*: The regular expression ones - `$~`, `$1`,
  etc. - and maybe some more I'm not remembering.
  
  {NRSER::Meta::Names::Var::Global} is meant to match those too.
  
  Background:
    Given I require 'nrser/meta/names'
    And the class {NRSER::Meta::Names::Var::Global}
  
  Scenario Outline: Match "common" global variable names
  
    When I construct an instance of the class from <string>
    
    Then the instance is an instance of the class
    And it has a {#common?} attribute that is `true`
    
    Examples:
      | string  |
      | "$BLAH" |
      | "$X"    |
      | "$_X"   |
    