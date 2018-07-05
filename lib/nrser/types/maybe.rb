# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require_relative './is_a'


# Namespace
# ========================================================================

module NRSER
module Types


# Definitions
# ========================================================================
  
class Maybe < Type
  
  # Attributes
  # ========================================================================
  
  # The type of all members besides `nil`.
  # 
  # @return [Type]
  #     
  attr_reader :type
  
    
  # Constructor
  # ======================================================================
  
  # Instantiate a new `NRSER::Types::Maybe`.
  def initialize type, **options
    super **options
    @type = NRSER::Types.make type
  end # #initialize
  
  
  # Instance Methods
  # ========================================================================
  
  def test? value
    value.nil? || @type.test?( value )
  end
  
  
  def explain
    "#{ @type.name }?"
  end
  
  
  def has_from_s?
    !@from_s.nil? || type.has_from_s?
  end
  
  
  def custom_from_s string
    type.from_s string
  end
  
end # class Maybe


# @!group Type Factory Functions
# ----------------------------------------------------------------------------

# @!method
#   Type satisfied by `nil` or the parametrized type.
#   
#   @param [Type] type
#     The type values must be if they are not `nil`.
#   
#   @param **options (see Type.initialize)
# 
#   @return [Type]
# 
def_factory :maybe do |type, **options|
  Maybe.new type, **options
end

# @!endgroup Type Factory Functions # ****************************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
