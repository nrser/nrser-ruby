Feature: Development - render a {NRSER::Text::Tag::List} as a block

  Background:
    Given I require "set"
    And I require "nrser/text/builder"
  
  
  Scenario: (1) Super-simple list - all items are single-line paragraphs
    When I let `builder` be:
      """ruby
        NRSER::Text::Builder.new( word_wrap: 74 ) do\
          
          p "A very simple block list..."
          
          list do
            item do
              p "Item one."
            end # item
            
            item do
              p "Item two."
            end # item
            
            item do
              p "Item three."
            end # item
          end # list
          
          p "...and we outta here!"
          
        end # Builder.new
      """
    
    And I let `strung` be `builder.render`
    
    Then `strung` is equal to the string:
      """
      A very simple block list...
      
      -   Item one.
          
      -   Item two.
          
      -   Item three.
      
      ...and we outta here!
      
      """
      
  
  Scenario: (2) List items are multiple paragraphs
    When I let `builder` be:
      """ruby
        NRSER::Text::Builder.new( word_wrap: 74 ) do\
          
          p "A very simple block list..."
          
          list do
            item do
              p "Item one."
              
              p "We have a cat."
            end # item
            
            item do
              p "Item two."
              
              p "She is the best cat."
            end # item
            
            item do
              p "Item three."
              
              p "She usually eat cat food."
            end # item
          end # list
          
          p "...and we outta here!"
          
        end # Builder.new
      """
    
    And I let `strung` be `builder.render`
    
    Then `strung` is equal to the string:
      """
      A very simple block list...
      
      -   Item one.
          
          We have a cat.
          
      -   Item two.
          
          She is the best cat.
          
      -   Item three.
          
          She usually eat cat food.
      
      ...and we outta here!
      
      """

  
  Scenario:
    When I let `builder` be:
      """ruby
        NRSER::Text::Builder.new( word_wrap: 74 ) do
          p "Here's a block list of some shit:"
          
          list do
            item do
              p "Item one: just a single line."
            end # item
            
            item do
              p "Item two:"
              
              p "Has more to it!"
              
              p "Ok, we're done here."
            end # item
            
            item do
              header "Item three"
              
              p "We're going to have a few *sections* in here!"
              
              section "Section 3.1" do
                p "First thing about item three."
                
                p "Blah blah blah."
              end
              
              section "Section 3.2" do
                p "Second thing about item three."
              end
            end # item
          end # list
        end # Builder.new
      """
    
    And I let `strung` be `builder.render`
    
    Then `strung` is equal to the string:
      """
      Here's a block list of some shit:
      
      -   Item one: just a single line.
          
      -   Item two:
          
          Has more to it!
          
          Ok, we're done here.
          
      -   ### Item three ###
          
          We're going to have a few *sections* in here!
          
          #### Section 3.1 ####
          
          First thing about item three.
          
          Blah blah blah.
          
          #### Section 3.2 ####
          
          Second thing about item three.
      
      """
