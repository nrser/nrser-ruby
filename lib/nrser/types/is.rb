
# Requirements
# ========================================================================

# Stdlib
# ------------------------------------------------------------------------

# Deps
# ------------------------------------------------------------------------

# Need {Module#anonymous?}
require 'active_support/core_ext/module/anonymous'

# Project / Package
# ------------------------------------------------------------------------

require_relative './type'

module NRSER::Types
  class Is < NRSER::Types::Type
    attr_reader :value
    
    def initialize value, **options
      super **options
      
      @value = value
    end
    
    def explain
      case value
      when Module
        module_type = if value.is_a?( Class ) then 'Class' else 'Module' end
        
        name = if value.anonymous?
          value.to_s.split( ':' ).last[0...-1]
        else
          value.name
        end
        
        "#{ module_type }<#{ name }>"
      else
        value.inspect
      end
    end
    
    def test? value
      @value.equal? value
    end
    
    def == other
      equal?(other) ||
      ( self.class == other.class &&
        @value == other.value )
    end
    
  end # Is
  
  # an exact value (using ===)
  def_factory :is do |value, **options|
    Is.new value, **options
  end
  
end # NRSER::Types
