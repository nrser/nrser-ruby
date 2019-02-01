# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ============================================================================

### Stdlib ###

### Deps ###

### Project / Package ###

require_relative "./is_a"
require_relative "./responds"


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# ========================================================================

# @!group Class Type Factories
# ----------------------------------------------------------------------------

# @!method self.Subclass cls, **options
#   Type for subclasses of {Class} `cls` (proper: `{ C | C < cls }` - in other
#   words, `cls` does **not** satisfy `Subclass(cls)`).
#   
#   @param [Class] cls
#     The class.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
# 
#   @raise [NRSER::TypeError]
#     If `cls` is not a {::Class}.
# 
def_type        :SubclassOf,
  parameterize: :cls,
  default_name: ->( cls, **options ) { "Class<#{ cls.safe_name }>" },
  # symbolic:     ->( cls, **options ) { "{C|C<#{ cls.safe_name }}" },
&->( cls, **options ) do
  unless cls.is_a? ::Class
    raise NRSER::TypeError.new \
      "Can only create subclass types from {Class} instances, found", cls,
      cls: cls
  end
  
  self.Intersection \
    self.IsA( ::Class ),
    self.Responds( to: [:<, cls], with: true ),
    **options
end # .Subclass


# @!method self.Superclass cls, **options
#   Type for superclasses of {Class} `cls` (proper: `{ C | C > cls }` - in 
#   other words, `cls` does **not** satisfy `Subclass(cls)`).
#   
#   @param [Class] cls
#     The class.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
# 
#   @raise [NRSER::TypeError]
#     If `cls` is not a {::Class}.
# 
def_type        :SuperclassOf,
  parameterize: :cls,
  default_name: ->( cls, **options ) { "Superclass<#{ cls.safe_name }>" },
  # symbolic:     ->( cls, **options ) { "{C|C<#{ cls.safe_name }}" },
&->( cls, **options ) do
  unless cls.is_a? ::Class
    raise NRSER::TypeError.new \
      "Can only create superclass types from {Class} instances, found", cls,
      cls: cls
  end

  self.Intersection \
    self.IsA( ::Class ),
    self.Responds( to: [:>, cls], with: true ),
    **options
end # .Superclass

# @!endgroup Class Type Factories # *********************************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER

