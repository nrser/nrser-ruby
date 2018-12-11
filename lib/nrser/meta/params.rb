# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------

require_relative './names'


# Refinements
# =======================================================================


# Namespace
# =======================================================================

module  NRSER
module  Meta

# Definitions
# =======================================================================


# @todo document Params class.
class Params
  
  # Constants
  # ========================================================================
  
  
  # Singleton Methods
  # ========================================================================
  
  
  # Attributes
  # ========================================================================
  
  
  # Construction
  # ========================================================================
  
  # Instantiate a new `Params`.
  def initialize
    @named_positional = {}
    @keyword = {}
    @block_name = nil
    @block = nil
  end # #initialize
  
  
  # Instance Methods
  # ========================================================================
  
  def call callable
    args = []
    kwds = {}
    
    # NOTE  `@block` is *always* passed, since it may not be explicitly declared
    #       in the `callable.parameters`
    
    callable.parameters.each do |(type, name)|
      case type
      when :req
        args << @named_positional.fetch( name )
      when :opt
        if @named_positional.key?( name )
          args << @named_positional[ name ]
        end
      when :keyreq
        kwds[ name ] = @keyword.fetch( name )
      when :key
        kwds[ name ] = @keyword[ name ] if @keyword.key?( name )
      when :rest
        raise "Can't deal with :rest param yet :/"
      when :block
        # pass
      else
        raise "Unknown param type: #{ type.inspect }"
      end
    end
    
    callable.call *args, **kwds, &@block
  end
  
  
  def []= name, value
    Names.match name,
      Names::PositionalParam, ->( param_name ) {
        @named_positional[ param_name.var_sym ] = value
      },
      
      Names::KeywordParam, ->( param_name ) {
        @keyword[ param_name.var_sym ] = value
      },
      
      Names::BlockParam, ->( param_name ) {
        @block_name = param_name.var_sym
        @block = value
      }
  end
  
  
end # class Params

# /Namespace
# =======================================================================

end # module Meta
end # module NRSER
