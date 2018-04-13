# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require_relative './type'


# Definitions
# =======================================================================

module NRSER::Types
  
  # Wraps an object as a type, using Ruby's "case equality" `===` to test
  # membership (like a `when` clause in a `case` expression).
  # 
  # Deals with some data loading too.
  # 
  # @note
  #   This was kinda hacked in when my idiot-ass figured out that all this
  #   types BS could fit in real well with Ruby's `===`, allowing types to
  #   be used in `when` clauses.
  #   
  #   Previously, {NRSER::Types.make} used to see if something was a module,
  #   and turn those into `is_a` types, and turn everything else into
  #   `is`, but this kind of sucked for a bunch of reasons I don't totally
  #   remember.
  #   
  #   Now, if a value is not a special case (like `nil`) or already a type,
  #   {NRSER::Types.make} turns it into a {When}.
  #   
  #   {When} instances are totally Ruby-centric, and are thus mostly to
  #   support in-runtime testing - you wouldn't want a {When} type to
  #   be part of an API schema or something - but they're really nice for
  #   the internal stuff.
  # 
  class When < Type
    
    # The wrapped {Object} whose `#===` will be used to test membership.
    # 
    # @return [Object]
    #     
    attr_reader :object
    
    
    # Constructor
    # ======================================================================
    
    # Instantiate a new `NRSER::Types::When`.
    def initialize object, **options
      super **options
      @object = object
    end # #initialize
    
    
    # Instance Methods
    # ======================================================================
    
    def test? value
      @object === value
    end
    
    
    def explain
      @object.inspect
    end
    
    # If {#object} responds to `#from_data`, call that and check results.
    # 
    # Otherwise, forward up to {NRSER::Types::Type#from_data}.
    # 
    # @param [Object] data
    #   Data to create the value from that will satisfy the type.
    # 
    # @return [Object]
    #   Instance of {#object}.
    # 
    def from_data data
      if @from_data.nil?
        if @object.respond_to? :from_data
          check @object.from_data( data )
        else
          super data
        end
      else
        @from_data.call data
      end
    end
    
    
    def has_from_data?
      @from_data || @object.respond_to?( :from_data )
    end
    
    
    def == other
      equal?( other ) ||
      ( self.class == other.class &&
        self.object == other.object )
    end
    
  end # class When
  
  
  def_factory :when do |value, **options|
    When.new value, **options
  end
  
end # module NRSER::Types
