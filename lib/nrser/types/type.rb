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
    # @param [nil | #call | #to_proc] to_data:
    #   
    # 
    def initialize name: nil, from_s: nil, to_data: nil, from_data: nil
      @name = name
      @from_s = from_s
      
      @to_data = if to_data.nil?
        nil
      elsif to_data.respond_to?( :call )
        to_data
      elsif to_data.respond_to?( :to_proc )
        to_data.to_proc
      else
        raise TypeError.new binding.erb <<-ERB
          `to_data:` keyword arg must be `nil`, respond to `#call` or respond
          to `#to_proc`.
          
          Found value:
          
              <%= to_data.pretty_inspect %>
          
          (type <%= to_data.class %>)
          
        ERB
      end
      
      @from_data = if from_data.nil?
        nil
      elsif from_data.respond_to?( :call )
        from_data
      elsif from_data.respond_to?( :to_proc )
        from_data.to_proc
      else
        raise TypeError.new binding.erb <<-ERB
          `to_data:` keyword arg must be `nil`, respond to `#call` or respond
          to `#to_proc`.
          
          Found value:
          
              <%= from_data.pretty_inspect %>
          
          (type <%= from_data.class %>)
          
        ERB
      end
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
    
    
    # Overridden to customize behavior for the {#from_s} and {#to_data} 
    # methods - those methods are always defined, but we have {#respond_to?}
    # return `false` if they lack the underlying instance variables needed
    # to execute.
    # 
    # @example
    #   t1 = t.where { |value| true }
    #   t1.respond_to? :from_s
    #   # => false
    #   
    #   t2 = t.where( from_s: ->(s){ s.split ',' } ) { |value| true }
    #   t2.respond_to? :from_s
    #   # => true
    # 
    # @param [Symbol | String] name
    #   Method name to ask about.
    # 
    # @param [Boolean] include_all
    #   IDK, part of Ruby API that is passed up to `super`.
    # 
    # @return [Boolean]
    # 
    def respond_to? name, include_all = false
      if name == :from_s || name == 'from_s'
        has_from_s?
      elsif name == :to_data || name == 'to_data'
        has_to_data?
      else
        super name, include_all
      end
    end # #respond_to?
    
    
    # Load a value of this type from a string representation by passing `s`
    # to the {@from_s} {Proc}.
    # 
    # Checks the value {@from_s} returns with {#check} before returning it, so
    # you know it satisfies this type.
    # 
    # @param [String] s
    #   String representation.
    # 
    # @return [Object]
    #   Value that has passed {#check}.
    # 
    # @raise [NoMethodError]
    #   If this type doesn't know how to load values from strings.
    #   
    #   In basic types this happens when {NRSER::Types::Type#initialize} was 
    #   not provided a `from_s:` {Proc} argument.
    #   
    #   {NRSER::Types::Type} subclasses may override {#from_s} entirely,
    #   divorcing it from the `from_s:` constructor argument and internal
    #   {@from_s} instance variable (which is why {@from_s} is not publicly
    #   exposed - it should not be assumed to dictate {#from_s} behavior 
    #   in general).
    # 
    # @raise [TypeError]
    #   If the value loaded does not pass {#check}.
    # 
    def from_s s
      if @from_s.nil?
        raise NoMethodError, "#from_s not defined"
      end
      
      check @from_s.call( s )
    end
    
    
    def from_data data
      if @from_data.nil?
        raise NoMethodError, "#from_data not defined"
      end
      
      check @from_data.call( data )
    end
    
    
    # Test if the type knows how to load values from strings.
    # 
    # If this method returns `true`, then we expect {#from_s} to succeed.
    # 
    # @return [Boolean]
    # 
    def has_from_s?
      ! @from_s.nil?
    end
    
    
    # Test if the type has custom information about how to convert it's values
    # into "data" - structures and values suitable for transportation and 
    # storage (JSON, etc.).
    # 
    # If this method returns `true` then {#to_data} should succeed.
    # 
    # @return [Boolean]
    # 
    def has_to_data?
      ! @to_data.nil?
    end # #has_to_data?
    
    
    def has_from_data?
      ! @from_data.nil?
    end
    
    
    # Dumps a value of this type to "data" - structures and values suitable
    # for transport and storage, such as dumping to JSON or YAML, etc.
    # 
    # @param [Object] value
    #   Value of this type (though it is *not* checked).
    # 
    # @return [Object]
    #   The data representation of the value.
    # 
    def to_data value
      if @to_data.nil?
        raise NoMethodError, "#to_data not defined"
      end
      
      @to_data.call value
    end # #to_data
    
    
    # Language Inter-Op
    # =====================================================================
    
    
    # @return [String]
    #   a brief string description of the type - just it's {#name} surrounded
    #   by some back-ticks to make it easy to see where it starts and stops.
    # 
    def to_s
      "`#{ name }`"
    end
    
    
    # Inspecting
    # ---------------------------------------------------------------------
    # 
    # Due to their combinatoric nature, types can quickly become large data
    # hierarchies, and the built-in {#inspect} will produce a massive dump
    # that's distracting and hard to decipher.
    # 
    # {#inspect} is readily used in tools like `pry` and `rspec`, significantly
    # impacting their usefulness when working with types.
    # 
    # As a solution, we alias the built-in `#inspect` as {#builtin_inspect},
    # so it's available in situations where you really want all those gory
    # details, and point {#inspect} to {#to_s}.
    # 
    
    alias_method :builtin_inspect, :inspect
    alias_method :inspect, :to_s
    
  end # Type
end # NRSER::Types