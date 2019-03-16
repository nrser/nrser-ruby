# encoding: UTF-8

require 'nrser/text'

def build &block
  puts NRSER::Text.build( &block ).render
end

def uni
  𝑎 = 123
  puts 𝑎 + 1
end
