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

require 'nrser/meta/props'


# Refinements
# =======================================================================

using NRSER::Types

# Declarations
# =======================================================================

module NRSER::Meta::Source; end


# Definitions
# =======================================================================

# @todo document NRSER::Meta::Source::Location class.
class NRSER::Meta::Source::Location < Hamster::Vector
  
  # Mixins
  # ============================================================================
  
  include NRSER::Meta::Props
  
  
  # Constants
  # ======================================================================
  
  
  # Class Methods
  # ======================================================================
  
  
  # Attributes
  # ======================================================================
  
  prop  :file, type: t.abs_path?, default: nil, key: 0
  prop  :line, type: t.pos_int?, default: nil, key: 1
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new `NRSER::Meta::Source::Location`.
  def initialize *args
    initialize_props \
      case args.length
      when 0
        { file: nil,
          line: nil }
      when 1
        case args[0]
        when nil
          { file: nil,
            line: nil }
        when Array
          { file: args[0][0],
            line: args[0][1] }
        when Hash
          args[0]
        when NRSER::Meta::Source::Location
          # TODO Props should handle this case automatically...
          args[0].to_h
        else
          raise TypeError.new binding.erb <<~END
            Single argument must be `nil`, `Array`, `Hash` or
            `NRSER::Meta::Source::Location`, found arg:
            
                <%= args[0].pretty_inspect %>
            
          END
        end
      when 2
        { file: args[0],
          line: args[1] }
      else
        raise ArgumentError.new binding.erb <<~END
          Expects at most two arguments, found args:
          
              <%= args.pretty_inspect %>
          
          END
      end
    
    super [file, line]
  end # #initialize
  
  
  # Instance Methods
  # ======================================================================
  
  
  
  # @todo Document valid? method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def valid?
    !( file.nil? && line.nil? )
  end # #valid?
  
  
  
  # @return [String]
  #   a short string describing the instance.
  # 
  def to_s
    "#{ file || '???' }:#{ line || '???' }"
  end # #to_s
  
  
  
end # class NRSER::Meta::Source::Location
