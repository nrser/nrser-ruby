Feature: Print values table/map things
  
  Background:
    Given I require "nrser/text/builder"
  
  
  Scenario:
    Given I let `builder` be:
      """ruby
        NRSER::Text::Builder.new( word_wrap: 74 ) {
          values a: 1, b: 2
        }
      """
    
    And I let `strung` be `builder.render`
    
    Then `strung` is equal to the string:
      """
          a = 1
          
          b = 2
      
      """
  
  
  Scenario:
    Given I let `builder` be:
      """ruby
        NRSER::Text::Builder.new( word_wrap: 74 ) {
          p "Here's some stuff up here."
          
          section "Context" do
            values \
              a: { short: "stuff" },
              b: {
                x: "Some long string so that pp breaks lines",
                y: "Yeah another long string long long string",
              }
          end
          
          section "Details" do
            p "Here be some additional *details* about what's going on."
          end
        }
      """
    
    And I let `strung` be `builder.render`
    
    Then `strung` is equal to the string:
      """
      Here's some stuff up here.
      
      Context
      --------------------------------------------------------------------------
      
          a = {:short=>"stuff"}
          
          b = {:x=>"Some long string so that pp breaks lines",
               :y=>"Yeah another long string long long string"}
      
      Details
      --------------------------------------------------------------------------
      
      Here be some additional *details* about what's going on.
      
      """
