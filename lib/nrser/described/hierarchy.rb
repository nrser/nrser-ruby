# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# =======================================================================

module  NRSER
module  Described


# Definitions
# =======================================================================

# Interface for description hierarchies, which manage the collection of
# {Described::Base} instances available.
#
# ### Semantics
#
# {Hierarchy} presents an {::Enumerable} collection interface, with methods to
# {#add} new descriptions and whose {#each} iteration order will be the search
# order for description references (see {#find_by_human_name}, etc.) and
# resolutions (see {Described::Base#resolve!}).
#
# In addition, 
#
# ### Current Status
#
# Incredibly basic at the moment, since I'm only supporting {::Cucumber}, which
# creates a new scenario instance - and hence a new {Hierarchy} - for step path,
# and therefore doesn't require any support for branching, which will likely
# lead to more complex re-ordering logic.
#
# This immediate use case seems satisfied by a simple array-mutating
# implementation ({Hierarchy::Array}).
#
# ### Future Plans
#
# The {Hierarchy} interface intends to be implementable in classes supporting
# branching, with {::RSpec} being the main consideration, though it seems likely
# it will want to some expansion to do so.
#
module Hierarchy
  
  # Singleton Methods
  # ========================================================================
  
  # Hook in on include to stick {::Enumerable} in there too.
  # 
  def self.included base
    base.send( :include, ::Enumerable ) unless base.include?( ::Enumerable )
  end
  
  
  # Instance Methods
  # ========================================================================
  
  # @!group Abstract Instance Methods
  # --------------------------------------------------------------------------
  # 
  # Implementing classes **MUST** define these.
  # 
  
  # Add a new {Described::Base} instance to the {Hierarchy}.
  # 
  # Immediately after a description is added, it should probably be returned
  # for {#current}.
  # 
  # @param [Described::Base] described
  #   New description to add.
  # 
  # @abstract
  # @raises [NRSER::AbstractMethodError]
  # 
  def add described
    raise NRSER::AbstractMethodError.new( self, __method__ )
  end
  
  
  # Iterate the descriptions in search / resolution order.
  # 
  # @overload each
  #   
  #   @return [::Enumerator<Described::Base>]
  #     That iterates over the descriptions.
  # 
  # @overload each &block
  #   
  #   @param [::Proc<(Described::Base)=>void>] block
  #     Calls `&block` once for each description, in order.
  #   
  #   @return [Hierarchy] self
  # 
  # @abstract
  # @raises [NRSER::AbstractMethodError]
  # 
  def each &block
    raise NRSER::AbstractMethodError.new( self, __method__ )
  end
  
  
  # Used to indicate that the description has been "touched", in the UNIX-sense.
  # 
  # This is very loosely defined, on purpose.
  # 
  # It can be used to affect the iteration ordering as necessary given the
  # desired behavior of subsequent operations on the hierarchy. In the 
  # {Hierarchy::Array} implementation used in Cucumber it causes the 
  # description to become {#current}, targeting it for subsequent "it"
  # references.
  # 
  # @see #find_by_human_name
  # 
  # @param [Described::Base] described
  #   The description that was touched.
  # 
  # @return [Described::Base]
  #   `described` parameter.
  # 
  # @abstract
  # @raises [NRSER::AbstractMethodError]
  # 
  def touch described
    raise NRSER::AbstractMethodError.new( self, __method__ )
  end
  
  # @!endgroup Abstract Instance Methods # ***********************************
  
  
  # Are the any descriptions in the {Hierarchy}?
  #
  # As {::Enumerable} does not implement `#empty?`, presumably because it
  # supports infinite iterables and streams (where {::Enumerable#count}
  # presumably hangs, returns {::Float::INFINITY}, raises, etc.), but it
  # seemed nice to have since it's easy for us.
  # 
  # @note 
  #   Though it's hard for me to imagine it making any material difference
  #   in a testing environment, implementations are likely to have a more
  #   direct/efficient method to test if the collection is empty.
  # 
  # @return [Boolean]
  #
  def empty?
    current.nil?
  end
  
  
  # Get the *current* descriptions, which defaults to the first one in the
  # iteration order, though implementations could override this behavior if it
  # desired.
  #
  # @note 
  #   Though it's hard for me to imagine it making any material difference
  #   in a testing environment, implementations are likely to have a more
  #   direct/efficient method to get the *current* description.
  #
  # @return [nil]
  #   If the {Hierarchy} is {#empty?}.
  #
  # @return [Described::Base]
  #   If the {Hierarchy} is not {#empty?}.
  #
  def current
    each.first
  end
  
  
  def resolve_all!
    # return if @all_resolved
    each { |described| described.resolve! self }
    # @all_resolved = true
    nil
  end
  
  
  # Essentially, find the first description that's an instance of a 
  # {Described::Base} subclass by matching one of it's {Base.human_names}.
  # 
  # @param [::String] human_name
  #   Something like "instance method" to find the first 
  #   {Described::InstanceMethod} instance (if any).
  #   
  #   Check out {Described::Base.human_names}.
  # 
  # @return [nil]
  #   No instance was of a class with the human name.
  # 
  # @return [Described::Base]
  #   The first matching description.
  # 
  def find_by_human_name human_name, touch: true
    find do |described|
      if described.class.human_names.include? human_name
        touch( described ) if touch
        true
      end
    end
  end
  
  
  # Same as {#find_by_human_name}, except it raises if nothing is found.
  # 
  # @param (see #find_by_human_name)
  # 
  # @return [Described::Base]
  #   The first matching description.
  # 
  # @raise [NotFoundError]
  #   If no matching description is found.
  # 
  def find_by_human_name! human_name, touch: true
    find_by_human_name( human_name, touch: touch ).tap do |described|
      if described.nil?
        raise NRSER::NotFoundError.new \
          "Could not find described instance in parent tree with human name",
          human_name.inspect,
          descriptions: map( &:to_s )
      end
    end
  end
  
  
  def find_by_class class_, touch: true
    find do |described|
      if described.is_a? class_
        touch( described ) if touch
        true
      end
    end
  end
  
  
  def find_by_class_name class_name
    find_by_class Described.class_for_name( class_name )
  end
  
  
  def find_by_class_name! class_name
    find_by_class_name( class_name ).tap do |described|
      if described.nil?
        raise NRSER::NotFoundError.new \
          "Could not find described class with name", class_name.inspect
      end
    end
  end
  
  
end # module Hierarchy


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
