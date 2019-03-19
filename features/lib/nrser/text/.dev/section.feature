Feature: Development - render sections with {NRSER::Text::Builder}

  Background:
    Given I require "set"
    And I require "nrser/text/builder"
  
  Scenario:
    When I let `a` be `Set[ 1, 2, 3 ]`
    And I let `b` be `Set[ 3, 4, 5 ]`
    
    And I let `builder` be:
      """ruby
        NRSER::Text::Builder.new( word_wrap: 74 ) {
          p ::Set, (list a, and: b), "are *not* disjoint, sharing", (a & b), '.'
          
          section "Details" do
            p "Here be some additional *details* about what's going on."
          end
        }
      """
    
    And I let `strung` be `builder.render`
    
    Then `strung` is equal to the string:
      """
      {Set} `#<Set: {1, 2, 3}>` and `#<Set: {3, 4, 5}>` are *not* disjoint,
      sharing `#<Set: {3}>`.
      
      Details
      --------------------------------------------------------------------------
      
      Here be some additional *details* about what's going on.
      
      """
  
  # Scenario:
  #   When I let `a` be `Set[ 1, 2, 3 ]`
  #   And I let `b` be `Set[ 3, 4, 5 ]`
    
  #   And I let `builder` be:
  #     """ruby
  #       NRSER::Text::Builder.new( word_wrap: 74 ) {
  #         p ::Set, (list a, and: b), "are *not* disjoint, sharing", (a & b), '.'
          
  #         section "Context" do
  #           values a: a, b: b
  #         end
          
  #         section "Details" do
  #           p "Here be some additional *details* about what's going on."
  #         end
  #       }
  #     """
    
  #   And I let `strung` be `builder.render`
    
  #   Then `strung` is equal to the string:
  #     """
  #     {Set} `#<Set: {1, 2, 3}>` and `#<Set: {3, 4, 5}>` are *not* disjoint,
  #     sharing `#<Set: {3}>`.
      
  #     Context
  #     ==========================================================================
      
  #     -   `a` ⇒ `#<Set: {1, 2, 3}>`
          
  #     -   `b` ⇒
          
  #             {
  #               x: 1,
  #               y: 2,
  #               z: 3
  #             }
      
  #     Details
  #     ==========================================================================
      
  #     Here be some additional *details* about what's going on.
      
  #     """