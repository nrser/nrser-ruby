# Refinements
# =======================================================================

require 'nrser/refinements'
using NRSER


# Definitions
# =======================================================================

module NRSER::Types
  class Type
    def self.short_name
      name.split('::').last
    end
    
    
    # Constructor
    # =====================================================================
    
    # Instantiate a new `NRSER::Types::Type`.
    # 
    # @param [nil | String] name:
    #   Name that will be used when displaying the type, or `nil` to use a
    #   default generated name.
    # 
    # @param [nil | #call] from_s:
    #   Callable that will be passed a {String} and should return an object 
    #   that satisfies the type if it possible to create one.
    #   
    #   The returned value *will* be checked against the type, so returning a 
    #   value that doesn't satisfy will result in a {TypeError} being raised
    #   by {#from_s}.
    # 
    def initialize name: nil, from_s: nil
      @name = name
      @from_s = from_s
    end # #initialize
    
    
    def name
      @name || default_name
    end
    
    def default_name
      self.class.short_name
    end
    
    def test value
      raise NotImplementedError
    end
    
    def check value, &make_fail_message
      # success case
      return value if test value
      
      msg = if make_fail_message
        make_fail_message.call type: self, value: value
      else
        NRSER.squish <<-END
          value #{ value.inspect } failed check #{ self.to_s }
        END
      end
      
      raise TypeError.new msg
    end
    
    def respond_to? name, include_all = false
      if name == :from_s || name == 'from_s'
        has_from_s?
      else
        super name, include_all
      end
    end
    
    def from_s s
      if @from_s.nil?
        raise NoMethodError, "#from_s not defined"
      end
      
      check @from_s.call( s )
    end
    
    def has_from_s?
      ! @from_s.nil?
    end
    
    def to_s
      "`Type: #{ name }`"
    end
  end # Type
end # NRSER::Types