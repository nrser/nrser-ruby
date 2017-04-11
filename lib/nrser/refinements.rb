require 'pathname'

require_relative 'refinements/string'
require_relative 'refinements/hash'
require_relative 'refinements/pathname'

module NRSER
  refine Object do
    def pipe
      yield self
    end
  end

  refine Exception do
    def format
      NRSER.format_exception self
    end
  end
  
  refine Binding do
    def erb str
      NRSER.template self, str
    end
  end  
end # NRSER
