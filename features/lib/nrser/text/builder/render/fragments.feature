Feature: Render an array of fragments using {NRSER::Text::Builder}
  
  I switched the Builder over to use an imperative style with tags, but hacked 
  in support for the original {::Array} style.
  
  All this does is wrap the array in a single {NRSER::Text::Tag::Paragraph}
  and render as usual.
  
  I don't think it's really recommended to use it like this anymore, but, hey,
  it's there...
  
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
  