Feature: {NRSER::Text::Builder} - Real use cases
  
  Work out how it works with actual use cases derived from existing code,
  focusing on complicated and complete examples.
  
  Background:
    Given I require "nrser/text/builder"
  
  
  Scenario: (1) From {I8::Struct.check_new_args!} error message
    
    Given I require 'i8/struct'
    
    And I let `vector_prop_defs` be:
      """ruby
        [ [ x: 1 ], [ y: 2 ] ]
      """
    
    And I let `hash_prop_defs` be:
      """ruby
        { x: 3, y: 4 }
      """
    
    And I let `builder` be:
      """ruby
        NRSER::Text::Builder.new( word_wrap: 74 ) {
          p "Exactly one of", args, "or", kwds, "must be empty."
        
          section "Details" do
            p I8::Struct.method( :new ), "proxies to either:"
            
            list ordered: true do
              item { p I8::Struct::Vector.method( :new ) }
              item { p I8::Struct::Hash.method( :new ) }
            end # list
            
            p "depending on *where* the property definitions are passed:"
            
            list ordered: true do
              item do
                p "Positionally in", args, "⇒", I8::Struct::Vector.method( :new )
              end
              
              item do
                p "By name in", kwds, "⇒", I8::Struct::Hash.method( :new )
              end
            end # list
            
            section "Examples" do
              list ordered: true do
                item do
                  p "Create a Point struct backed by an", I8::Vector, ":"
                  
                  ruby { "Point = I8::Struct.new [x: t.int], [y: t.int]" }
                end
                
                item do
                  p "Create a Point struct backed by an", I8::Hash, ":"
                  
                  ruby { "Point = I8::Struct.new x: t.int, y: t.int" }
                end
              end # list
            end # Examples
          end # Details
          
          section "Context" do
            values \
              args: vector_prop_defs,
              kwds: hash_prop_defs
          end # Context
        }
      """
    
    And I let `strung` be `builder.render`
    
    Then `strung` is equal to the string:
      """
      Exactly one of `*args` or `**kwds` must be empty.
      
      Details
      --------------------------------------------------------------------------
      
      {I8::Struct.new} proxies to either:
      
      1.  {I8::Struct::Vector.new}
          
      2.  {I8::Struct::Hash.new}
      
      depending on *where* the property definitions are passed:
      
      1.  Positionally in `*args` ⇒ {I8::Struct::Vector.new}
          
      2.  By name in `**kwds` ⇒ {I8::Struct::Hash.new}
      
      ### Examples ###
      
      1.  Create a Point struct backed by an {I8::Vector}:
          
              Point = I8::Struct.new [x: t.int], [y: t.int]
          
      2.  Create a Point struct backed by an {I8::Hash}:
          
              Point = I8::Struct.new x: t.int, y: t.int
      
      Context
      --------------------------------------------------------------------------
      
          args = [[{:x=>1}], [{:y=>2}]]
          
          kwds = {:x=>3, :y=>4}
      
      """