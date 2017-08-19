module NRSER
module Meta 
module Props 

class Base
  include NRSER::Meta::Props
  
  def initialize **values
    initialize_props values
  end
end # class Base

end # module Props
end # module Meta
end # module NRSER
