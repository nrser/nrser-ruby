# encoding: UTF-8
# frozen_string_literal: true

require 'nrser/meta/names'


# Namespace
# =======================================================================

module  NRSER
module  Described
module  RSpec
module  ExampleGroup
module  Describe


# Definitions
# ========================================================================

# Describe a method of the parent subject.
# 
# @param [Method | Symbol | String] method
#   The method being described:
#   
#   1.  {Method} instance - used directly.
#       
#   2.  {Symbol}, {String} - 
# 
# @return [void]
# 
def describe_method method,
                    *description,
                    **metadata,
                    &body
  
  case method
  when ::Method
    DESCRIBE :method, subject: method, &body
  
  else
    Meta::Names.match method,
      Meta::Names::Method::Explicit::Singleton, ->( method_name ) {
        const = method_name.receiver_name.constantize
        method = const.method method_name.bare_name
        
        DESCRIBE :method, subject: method, &body
      },
      
      Meta::Names::Method::Singleton, ->( method_name ) {
        DESCRIBE :method, name: method_name.bare_name, &body
      },
      
      Meta::Names::Method::Bare, ->( method_name ) {
        DESCRIBE :method, name: method_name.bare_name, &body
      }
  end
end # #describe_method

alias_method :METHOD, :describe_method


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpec
end # module Described
end # module NRSER
