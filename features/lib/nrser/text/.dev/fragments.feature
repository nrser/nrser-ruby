Feature: Development - render an array of fragments using {NRSER::Text::Builder}
  
  I'm switching the Builder over to use an imperative style with tags, but it
  might be nice to still be able to just render fragments into a line?
  
  Background:
    Given I require "set"
    And I require "nrser/text/builder"
  
  Scenario:
    When I let `a` be `Set[ 1, 2, 3 ]`
    And I let `b` be `Set[ 3, 4, 5 ]`
    
    And I let `builder` be:
      """ruby
        NRSER::Text::Builder.p( word_wrap: 74 ) {[
          ::Set, list( a, and: b ), "are *not* disjoint, sharing", (a & b)
        ]}
      """
    
    And I let `strung` be `builder.render`
    
    Then `strung` is equal to the string:
      """
      {Set} `#<Set: {1, 2, 3}>` and `#<Set: {3, 4, 5}>` are *not* disjoint,
      sharing `#<Set: {3}>`
      
      """
  