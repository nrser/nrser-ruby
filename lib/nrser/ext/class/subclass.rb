# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# ========================================================================

module  NRSER
module  Ext
module  Class


# Definitions
# ========================================================================

# A safe version of `<`: tests first if `object` is a {::Class}, then if
# `object < self`.
# 
# @example
#   require 'nrser/ext/class/subclass'
#   
#   class A
#     extend NRSER::Ext::Class
#   end
#   
#   # Parameter does not need to be a {::Class}
#   A.subclass? 'hey'
#   #=> false
#   
#   # Tests for *proper* subclasses (not `<=`)
#   A.subclass? A
#   #=> false
#   
#   class B < A; end
#   
#   A.subclass? B
#   #=> true
# 
# @param [::Object] object
#   Anything at all.
# 
# @return [Boolean]
#   `true` if `object` is a (proper) subclass of this class.
# 
def subclass? object
  object.is_a?( ::Class ) && object < self
end


# /Namespace
# ========================================================================

end # module Class
end # module Ext
end # module NRSER