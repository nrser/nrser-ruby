require_relative './string'

module NRSER
  class << self

    def erb bnd, str
      require 'erb'
      filter_repeated_blank_lines ERB.new(dedent(str)).result(bnd)
    end # erb

    alias_method :template, :erb
    
  end # class << self
end # module NRSER
