Feature: Render {NRSER::Text::Tag::Code} blocks
  
  Background:
    Given I require "nrser/text/builder"
  
  
  Scenario:
    Given I let `builder` be:
      """ruby
        NRSER::Text::Builder.new( word_wrap: 74 ) {
          p "Have some code:"
          
          code do
            { a: 1, b: 2 }
          end
        }
      """
    
    And I let `strung` be `builder.render`
    
    Then `strung` is equal to the string:
      """
      Have some code:
      
          {:a=>1, :b=>2}
      
      """
