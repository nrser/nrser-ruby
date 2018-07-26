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


# Refinements
# =======================================================================


# Namespace
# =======================================================================

module  NRSER

# Definitions
# =======================================================================


# @todo document Selector class.
class Selector

  class Eq
    def initialize value
      @value = value
    end

    def match value
      @value == value
    end
  end


  class KV
    def initialize assoc
    end
  end

  
  # Constants
  # ========================================================================
  
  
  # Class Methods
  # ========================================================================

  
  # @todo Document from method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.from term
    case term
    when Selector
      term
    when t.map
      KV.from term
    when t.bag
      In.from term
    else
      Eq.from term
    end
  end # .from
  
  
  # Attributes
  # ========================================================================
  
  
  # Construction
  # ========================================================================
  
  # Instantiate a new `Selector`.
  def initialize terms
    terms.map { |term|

    }
  end # #initialize
  
  
  # Instance Methods
  # ========================================================================

  def match entry

  end
  
end # class Selector


# /Namespace
# =======================================================================

end # module NRSER
