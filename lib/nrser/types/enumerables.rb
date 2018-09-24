# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Need {Module.safe_name}
require 'nrser/core_ext/module/names'

# Need {Types.Top} for the default entry type
require_relative './top'


# Namespace
# =======================================================================

module  NRSER
module  Types


# Definitions
# =======================================================================

# Type class that parameterizes {Enumerable} values of a homogeneous type.
# 
# @example
#   array_of_int = NRSER::Types::EnumerableType.new Array, Integer
#   array_of_int.test? [1, 2, 3]          #=> true
#   array_of_int.test? [1, 2, 'three']    #=> false
#   array_of_int.test? 'blah'             #=> false
#   array_of_int.test? []                 #=> true
# 
class EnumerableType < IsA
  
  # Attributes
  # ========================================================================

  # Type all entries must satisfy.
  # 
  # @return [Type]
  #     
  attr_reader :entry_type
  
  
  # Construction
  # ========================================================================
  
  # Instantiate a new `EnumerableType`.
  def initialize  enumerable_type = ::Enumerable,
                  entry_type = self.Top,
                  **options
    super enumerable_type, **options
    @entry_type = Types.make entry_type
  end # #initialize
  
  
  # Instance Methods
  # ========================================================================

  # @!group Display Instance Methods
  # ------------------------------------------------------------------------

  def explain
    "#{ enumerable_type.safe_name }<#{ entry_type.explain }>"
  end

  # @!endgroup Display Instance Methods # ************************************


  # Intuitive alias for {IsA#mod}.
  # 
  # @return [Class]
  # 
  def enumerable_type; mod; end


  def test? value
    # Test that `value` is of the right container class first
    return false unless super( value )

    # If that passed test all the entries against the type
    value.all? &@entry_type.method( :test? )
  end
  
  
end # class EnumerableType


# @!group Enumerable Type Factories
# --------------------------------------------------------------------------

#@!method self.Enumerable **options
#   Types that parameterize {Enumerable} values of a homogeneous type.
#   
#   @param [Class] enumerable_type
#     Required class of the container itself.
#   
#   @param [Type | Object] entry_type
#     Type of the entries. If this is not a {Type}, one will be created from 
#     it via {NRSER::Types.make}.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :Enumerable,
  aliases:      [ :Enum, :enum ],
  parameterize: [ :enumerable_type, :entry_type ],
&->( enumerable_type = ::Enumerable, entry_type = self.Top, **options ) do
  EnumerableType.new enumerable_type, entry_type, **options
end # .Enumerable


# @!endgroup Enumerable Type Factories # ***********************************

# /Namespace
# =======================================================================

end # module  Types
end # module  NRSER
