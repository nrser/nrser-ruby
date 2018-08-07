# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require_relative './type'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# =======================================================================

# Negation {Type} - A {Type} that parameterizes another {#type} by admitting
# values that the {#type} does not.
# 
# @note
#   Construct {Not} types using the {.Not} factory.
#
class Not < Type

  # The type this one isn't.
  # 
  # @return [Type]
  #     
  attr_reader :type

  
  # Constructor
  # ======================================================================
  
  # Instantiate a new `NRSER::Types::Not`.
  def initialize type, **options
    super **options
    @type = NRSER::Types.make type
  end # #initialize
  
  
  # Instance Methods
  # ======================================================================
  
  def test? value
    ! type.test( value )
  end
  

  def default_symbolic
    "#{ NRSER::Types.Top.symbolic }#{ COMPLEMENT }#{ type.symbolic }"
  end


  def default_name
    "#{ NOT }#{ type.name }"
  end

  
  def explain
    "#{ self.class.demod_name }<#{ type.explain }>"
  end
  
end # class Not


# @!group Negation Type Factories
# ----------------------------------------------------------------------------

#@!method self.Not **options
#   Negates another type.
#   
#   @param [TYPE] type
#     The type to negate, made into one via {.make} if it's not already.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Not]
#   
def_type        :Not,
  default_name: false,
  parameterize: :type,
&->( type, **options ) do
  Not.new type, **options
end # .Not

# @!endgroup Negation Type Factories # ***************************************


# /Namespace
# ========================================================================

end # module  NRSER
end #module  Types
