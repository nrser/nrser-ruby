Feature: Render {NRSER::Text::Tag::Values} table/map things
  
  {NRSER::Text::Tag::Values} are name/value maps ({::Hash} instances underneath)
  that are rendered in {NRSER::Text::Tag::Code} blocks in a sort of table 
  layout.
  
  These are the primarily to support rendering the {NRSER::NicerError#context}
  in nicer errors, but they seem like they may be useful any time you want to
  print out some bound values.
  
  Background:
    Given I require "nrser/text/builder"
  
  
  Scenario: (1) The most basic example
    
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
  
  
  Scenario: (2) Include a {::Hash} with more data to test word wrapping
    
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
