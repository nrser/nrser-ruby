# encoding: UTF-8
# frozen_string_literal: true

# Namespace
# =======================================================================

module  NRSER
module  Described
module  RSpec
module  ExampleGroup
module  Describe


# Definitions
# ========================================================================

def INSTANCE_METHOD method,
                    *description,
                    **metadata,
                    &body
  
  case method
  when ::UnboundMethod
    DESCRIBE :instance_method, *description, subject: method, &body
    
  else
    Meta::Names.match method,
      Meta::Names::Method::Explicit::Instance, ->( method_name ) {
        const = method_name.receiver_name.constantize
        unbound_method = const.instance_method method_name.bare_name
        DESCRIBE :instance_method, *description, subject: unbound_method, &body
      },
      
      Meta::Names::Method::Instance, ->( method_name ) {
        DESCRIBE :instance_method, *description, name: method_name.bare_name, &body
      },
      
      Meta::Names::Method::Bare, ->( method_name ) {
        DESCRIBE :instance_method, *description, name: method_name, &body
      }
  end
end # #INSTANCE_METHOD


# /Namespace
# ========================================================================

end # module  Describe
end # module  ExampleGroup
end # module  RSpec
end # module  Described
end # module  NRSER
