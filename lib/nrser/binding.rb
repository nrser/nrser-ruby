require_relative './string'

module NRSER
  class << self

    def erb bnd, str
      require 'erb'
      
      filter_repeated_blank_lines(
        with_indent_tagged( dedent( str ) ) { |tagged_str|
          ERB.new( tagged_str ).result( bnd )
        },
        remove_leading: true
      )
    end # erb

    alias_method :template, :erb
    
  end # class << self
end # module NRSER
