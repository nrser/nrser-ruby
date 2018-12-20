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

# Uses logging
require 'nrser/log'

# Matches named parameters using {Names}
require_relative './names'


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  Meta

# Definitions
# =======================================================================


# @todo document Params class.
class Params
  
  # Mixins
  # ========================================================================
  
  include NRSER::Log::Mixin #; logger.level = :trace
  
  
  # Construction
  # ========================================================================
  
  # Instantiate a new `Params`.
  def initialize  named: {},
                  args: [],
                  kwds: {},
                  block: nil,
                  block_name: nil
    @positional = {}
    @keyword = {}
    @block = block
    @block_name = block_name
    
    named.each { |name, value| set name, value }
    args.each_with_index { |value, index| set index, value }
    kwds.each { |name, value| set "#{ name }:", value }
  end # #initialize
  
  
  # Instance Methods
  # ========================================================================
  
  def call callable
    args = []
    kwds = {}
    
    positional = @positional.dup
    keyword = @keyword.dup
    
    # NOTE  `@block` is *always* passed, since it may not be explicitly declared
    #       in the `callable.parameters`
    
    callable.parameters.each_with_index do |(type, name), index|
      case type
      when :req, :opt
        if positional.key?( index ) && positional.key?( name )
          raise NRSER::ConflictError.new \
            "Value set for positional parameter by both name and index",
            name: name,
            name_value: positional[ name ],
            index: index,
            index_value: positional[ index ]
        end
        
        if positional.key?( index )
          args << positional.delete( index )
        elsif positional.key?( name )
          args << positional.delete( name )
        elsif type == :req
          raise NRSER::ArgumentError.new \
            "Argument", name, "at index", index, "is required, but no value",
            "is available",
            callable: callable,
            callable_parameters: callable.parameters,
            params: self
        end
      when :keyreq, :key
        if keywords.key? name
          kwds[ name ] = keywords.delete( name )
        elsif type == :keyreq
          raise NRSER::ArgumentError.new \
            "Keyword argument", name, "is required, but no value is available",
            callable: callable,
            callable_parameters: callable.parameters,
            params: self
        end
      when :rest
        # raise "Can't deal with :rest param yet :/"
        
        logger.trace "Found :rest parameter, pushing rest of positional" do {
          parameters: callable.parameters,
          positional: positional,
          self: self
        } end
          
        positional.keys.select { |i| i >= index }.sort.each { |i|
          args << positional.delete( i )
        }
        
      when :block
        # pass
      else
        raise "Unknown param type: #{ type.inspect }"
      end
    end
    
        
    logger.trace "Calling",
      args: args,
      kwds: kwds,
      block: @block
    
    args << kwds unless kwds.empty?
    
    callable.call *args, &@block
  end
  
  
  def set name, value
    Names.match name,
      t.Index, ->( index ) {
        @positional[ index ] = value  
      },
      
      Names::PositionalParam, ->( param_name ) {
        @positional[ param_name.var_sym ] = value
      },
      
      Names::KeywordParam, ->( param_name ) {
        @keyword[ param_name.var_sym ] = value
      },
      
      Names::BlockParam, ->( param_name ) {
        @block_name = param_name.var_sym
        @block = value
      }
  end
  
  alias_method :[]=, :set
  
  
end # class Params

# /Namespace
# =======================================================================

end # module Meta
end # module NRSER
