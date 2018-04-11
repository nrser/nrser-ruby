# encoding: UTF-8
# frozen_string_literal: true
  
module NRSER::Types
  
  # A type for anything - {#test?} always returns `true`.
  # 
  class AnyType < NRSER::Types::Type
    
    def test? value; true; end
    def explain; '*'; end
    def custom_from_s string; string; end
    
    # {AnyType} instances are all equal.
    # 
    # @note
    #   `other`'s class must be {AnyType} exactly - we make no assumptions
    #   about anything that has subclasses {AnyType}.
    # 
    # @param [*] other
    #   Object to compare to.
    # 
    # @return [Boolean]
    #   `true` if `other#class` equals {AnyType}.
    # 
    def == other
      other.class == AnyType
    end
    
  end # class Any
  
  # Anything at all...
  # 
  def_factory(
    :any,
    aliases: [ :all ],
  ) do
    @_any_type_instance ||= AnyType.new
  end
  
end # NRSER::Types
