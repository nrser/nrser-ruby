Feature: {NRSER::Text::Builder} - Render {Method} objects

  Background:
    Given I require "nrser/text/builder"
  
  Scenario:
    Given I let `builder` be:
      """ruby
        NRSER::Text::Builder.new( word_wrap: 74 ) {
          p NRSER::Text.method( :default_renderer ),
            "gets the default renderer."
        }
      """
    
    And I let `strung` be `builder.render`
    
    Then `strung` is equal to the string:
      """
      {NRSER::Text.default_renderer} gets the default renderer.
      """