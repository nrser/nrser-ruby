Feature: Render {NRSER::Text::Tag::Code} blocks
  
  Background:
    Given I require "nrser/text/builder"
  
  
  Scenario: (1) Regular code block (no {NRSER::Text::Tag::Code#syntax})
    Given I let `builder` be:
      """ruby
        NRSER::Text::Builder.new( word_wrap: 74 ) {
          p "Have some code:"
          
          code do
            "{ a: 1, b: 2 }"
          end
        }
      """
    
    And I let `strung` be `builder.render`
    
    Then `strung` is equal to the string:
      """
      Have some code:
      
          { a: 1, b: 2 }
      
      """
      
      
  Scenario: (2) Code block with {NRSER::Text::Tag::Code#syntax}
    
    Syntax highlighting is turned off for Cucumber tests, because it's just too
    much of a pain to write out the escape sequences, so we won't see any 
    rendering difference here, but we can check that the call worked as 
    expected.
    
    Given I let `builder` be:
      """ruby
        NRSER::Text::Builder.new( word_wrap: 74 ) {
          p "Have some Ruby:"
          
          code syntax: :ruby do
            "{ a: 1, b: 2 }"
          end
        }
      """
    
    And I let `code_tag` be `builder.blocks[ 1 ]`
    And I let `strung` be `builder.render`
    
    Then `code_tag` is a {NRSER::Text::Tag::Code}
    And it has a `syntax` attribute that is `:ruby`
    
    And `strung` is equal to the string:
      """
      Have some Ruby:
      
          { a: 1, b: 2 }
      
      """
  
  
  Scenario: (3) Ruby code block
    
    Create and render a {NRSER::Text::Tag::Code} block with `:ruby` syntax
    using the {NRSER::Text::Builder#ruby} shortcut.
    
    Given I let `builder` be:
      """ruby
        NRSER::Text::Builder.new( word_wrap: 74 ) {
          p "Have some more Ruby:"
          
          ruby do
            "{ a: 1, b: 2 }"
          end
        }
      """
    
    And I let `code_tag` be `builder.blocks[ 1 ]`
    And I let `strung` be `builder.render`
    
    Then `code_tag` is a {NRSER::Text::Tag::Code}
    And it has a `syntax` attribute that is `:ruby`
    
    And `strung` is equal to the string:
      """
      Have some more Ruby:
      
          { a: 1, b: 2 }
      
      """

