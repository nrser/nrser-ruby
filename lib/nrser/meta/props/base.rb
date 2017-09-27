# Refinements
# =======================================================================

require 'nrser/refinements'
using NRSER


module NRSER
module Meta 
module Props 

class Base
  include NRSER::Meta::Props
  
  def initialize **values
    initialize_props values
  end
  
  # @todo Prob wanna improve this at some point, but it's better than nothing.
  # 
  # @return [String]
  #   a short string describing the instance.
  # 
  def to_s
    props_str = self.class.props( only_primary: true ).sort.map { |name, prop|
      "#{ name }=#{ prop.get( self ).inspect }"
    }.join ' '
    
    <<-END.squish
      #<#{ self.class.name } #{ props_str }>
    END
  end # #to_s
end # class Base

end # module Props
end # module Meta
end # module NRSER
