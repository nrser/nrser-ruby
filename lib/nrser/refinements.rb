require_relative './refinements/object'
require_relative './refinements/string'
require_relative './refinements/hash'
require_relative './refinements/pathname'

module NRSER
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
