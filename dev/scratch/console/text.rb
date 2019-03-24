# encoding: UTF-8

require 'nrser/text'
require 'nrser/text/builder'

def build &block
  puts NRSER::Text.build( &block ).render
end

def uni
  𝑎 = 123
  puts 𝑎 + 1
end


def text_tmp
  builder = NRSER::Text::Builder.new( word_wrap: 74 ) do    
    p "A very simple block list..."
    
    list do
      item do
        p "Item one."
        
        p "We have a cat."
      end # item
      
      item do
        p "Item two."
        
        p "She is the best cat!"
      end # item
      
      item do
        p "Item three."
        
        p "She usually eat cat food."
      end # item
    end # list
    
    p "...and we outta here!"
  end # Builder.new
  
  puts builder.render
end
