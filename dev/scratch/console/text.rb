# encoding: UTF-8

require 'nrser/text'
require 'nrser/text/writer'

$lines = File.read( 'README.md' ).lines.
  select { |l| l.length > 40 && !l.start_with?( "-" ) && !l.start_with?( "=" ) }

def lines; $lines; end

$writer = NRSER::Text::Writer.new io: $stdout, line_width: 40

def w; $writer; end
  
